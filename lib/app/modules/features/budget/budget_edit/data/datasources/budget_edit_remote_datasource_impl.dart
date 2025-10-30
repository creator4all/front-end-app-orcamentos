import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../../../../services/api_service.dart';
import '../../../budget_config/data/models/product_dto.dart';
import '../../../shared/models/budget_update_dto.dart';
import '../models/budget_edit_dto.dart';
import 'budget_edit_remote_datasource.dart';

/// Função Top-Level para ser executada em Isolate
/// Recebe uma string JSON, decodifica e mapeia para uma lista de ProductDTO
List<ProductDTO> _parseProductsInIsolate(String jsonString) {
  try {
    final jsonResponse = jsonDecode(jsonString) as Map<String, dynamic>;

    // Chave para encontrar a lista de produtos
    dynamic productList;

    // Estratégia 1: Tentar encontrar 'data.dados.produtos'
    if (jsonResponse.containsKey('data')) {
      final data = jsonResponse['data'] as Map<String, dynamic>?;
      if (data != null && data.containsKey('dados')) {
        final dados = data['dados'] as Map<String, dynamic>?;
        if (dados != null && dados.containsKey('produtos')) {
          productList = dados['produtos'];
        }
      }
    }
    // Estratégia 2: Tentar encontrar 'dados.produtos'
    else if (jsonResponse.containsKey('dados')) {
      final dados = jsonResponse['dados'] as Map<String, dynamic>?;
      if (dados != null && dados.containsKey('produtos')) {
        productList = dados['produtos'];
      }
    }

    // Se encontrou a lista e ela é uma lista
    if (productList != null && productList is List) {
      return productList
          .map((json) => ProductDTO.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    // Se não encontrou, retorna lista vazia
    return [];
  } catch (e) {
    // Em caso de erro no parse, retorna lista vazia para não quebrar a app
    // O ideal seria logar esse erro em um serviço de monitoramento
    return [];
  }
}

class BudgetEditRemoteDataSourceImpl implements BudgetEditRemoteDataSource {
  final ApiService apiService;

  BudgetEditRemoteDataSourceImpl(this.apiService);

  @override
  Future<BudgetEditDto> getBudgetForEdit(int id) async {
    try {
      final response = await apiService.get('/api/orcamentos/$id');

      // ApiService envolve em { success: true, data: {...} }
      // Então precisamos acessar response['data']['dados']
      final data = response['data']?['dados'] ?? response['data'] ?? response;

      return BudgetEditDto.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getBudgetProductsComplete(int id) async {
    try {
      debugPrint(
          '🌐 [BudgetEdit-DataSource] GET /api/orcamentos/$id/produtos-completos');

      // ✅ Usar ResponseType.bytes para receber bytes crus
      // Depois fazemos decode UTF-8 MANUAL para evitar corrupção de caracteres especiais
      // Necessário porque JSON tem 114KB+ (5000+ linhas) e Dio não consegue fazer auto-parse
      final response = await apiService.get(
        '/api/orcamentos/$id/produtos-completos',
        responseType: ResponseType.bytes,
      );

      // Verificar se API retornou erro
      if (response.containsKey('success') && response['success'] == false) {
        final errorMsg =
            response['error'] ?? response['message'] ?? 'Erro desconhecido';
        debugPrint('❌ [BudgetEdit-DataSource] API retornou erro: $errorMsg');
        throw Exception('Erro ao buscar produtos: $errorMsg');
      }

      // Extrair bytes da resposta
      if (!response.containsKey('data')) {
        debugPrint(
            '❌ [BudgetEdit-DataSource] Resposta não contém dados em "data"');
        throw Exception('Resposta da API em formato inválido');
      }

      final dynamic rawData = response['data'];

      // Converter bytes para String com UTF-8 EXPLÍCITO
      String jsonString;

      if (rawData is List<int>) {
        // ✅ DECODE UTF-8 MANUAL - Garante que caracteres especiais (ê, ó, á, ã) sejam preservados
        jsonString = utf8.decode(rawData, allowMalformed: false);
        debugPrint(
            '📦 [BudgetEdit-DataSource] Bytes decodificados com UTF-8: ${jsonString.length} chars');
      } else if (rawData is String) {
        // Fallback: se já vier como string (não deveria acontecer com ResponseType.bytes)
        jsonString = rawData;
        debugPrint(
            '⚠️ [BudgetEdit-DataSource] Dados já vieram como String: ${jsonString.length} chars');
      } else {
        debugPrint(
            '❌ [BudgetEdit-DataSource] Tipo de dados inesperado: ${rawData.runtimeType}');
        throw Exception('Formato de resposta inválido');
      }

      debugPrint(
          '🚀 [BudgetEdit-DataSource] Iniciando parse em Isolate com compute()...');

      // 🚀 Parse assíncrono em isolate para não travar a UI
      final produtos = await compute(_parseProductsInIsolate, jsonString);

      debugPrint(
          '✅ [BudgetEdit-DataSource] ${produtos.length} produtos parseados com sucesso via Isolate');

      // Retornar no formato esperado pelo repository
      // Repository espera Map com chave 'produtos' contendo lista de Map<String, dynamic>
      return {
        'orcamento_id': id,
        'total_produtos': produtos.length,
        'produtos': produtos.map((p) => p.toJson()).toList(),
      };
    } on DioException catch (e) {
      debugPrint('❌ [BudgetEdit-DataSource] DioException: ${e.message}');
      debugPrint('   Status: ${e.response?.statusCode}');
      debugPrint('   Data: ${e.response?.data}');
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      debugPrint('❌ [BudgetEdit-DataSource] Exceção: $e');
      debugPrint('Stack: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<BudgetEditDto> updateBudget({
    required int id,
    String? name,
    int? validityDays,
    DateTime? validityDate,
    String? status,
    bool? isArchived,
    List<int>? selectedProductIds,
  }) async {
    try {
      final Map<String, dynamic> body = {};

      if (name != null) body['nome'] = name;
      if (validityDays != null) body['orc_dias_validade'] = validityDays;
      if (validityDate != null) {
        body['orc_data_validade'] = validityDate.toIso8601String();
      }
      if (status != null) body['orc_status'] = status;
      if (selectedProductIds != null) {
        body['produtos_selecionados'] = selectedProductIds;
      }

      final response = await apiService.put('/api/orcamentos/$id', body);

      // ApiService envolve em { success: true, data: {...} }
      // Então precisamos acessar response['data']['dados']
      final data = response['data']?['dados'] ?? response['data'] ?? response;

      return BudgetEditDto.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<BudgetEditDto> updateBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  }) async {
    try {
      // Converter DTO para JSON (apenas campos não-nulos)
      final body = updateData.toJson();

      final response = await apiService.put('/api/orcamentos/$budgetId', body);

      // Extrair dados da resposta
      Map<String, dynamic> data;

      if (response.containsKey('dados')) {
        data = response['dados'] as Map<String, dynamic>;
      } else if (response.containsKey('data')) {
        final dataField = response['data'];
        if (dataField is Map && dataField.containsKey('dados')) {
          data = dataField['dados'] as Map<String, dynamic>;
        } else {
          data = dataField as Map<String, dynamic>;
        }
      } else {
        data = response;
      }

      return BudgetEditDto.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Timeout na conexão com o servidor');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return Exception('Orçamento não encontrado');
        } else if (statusCode == 401 || statusCode == 403) {
          return Exception('Não autorizado');
        }
        return Exception('Erro no servidor: ${error.response?.data}');
      case DioExceptionType.cancel:
        return Exception('Requisição cancelada');
      case DioExceptionType.connectionError:
        return Exception('Sem conexão com a internet');
      default:
        return Exception('Erro desconhecido: ${error.message}');
    }
  }
}
