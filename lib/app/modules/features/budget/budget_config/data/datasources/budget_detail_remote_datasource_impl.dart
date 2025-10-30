import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../../../../services/api_service.dart';
import '../../../shared/models/budget_update_dto.dart';
import '../models/budget_detail_dto.dart';
import '../models/product_dto.dart';
import 'budget_detail_remote_datasource.dart';

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

/// Implementação concreta do BudgetDetailRemoteDataSource usando Dio/ApiService
class BudgetDetailRemoteDataSourceImpl implements BudgetDetailRemoteDataSource {
  final ApiService apiService;

  BudgetDetailRemoteDataSourceImpl(this.apiService);

  @override
  Future<BudgetDetailDto> getBudgetById(int id) async {
    try {
      final response = await apiService.get('/api/orcamentos/$id');

      // Extrair dados da resposta
      Map<String, dynamic> data;

      if (response.containsKey('dados')) {
        // Caso: {dados: {...}}
        data = response['dados'] as Map<String, dynamic>;
      } else if (response.containsKey('data')) {
        // Caso: {data: {...}}
        final dataField = response['data'];
        if (dataField is Map && dataField.containsKey('dados')) {
          // Caso: {data: {dados: {...}}}
          data = dataField['dados'] as Map<String, dynamic>;
        } else {
          // Caso: {data: {...}} direto
          data = dataField as Map<String, dynamic>;
        }
      } else {
        // Caso: já é o objeto direto
        data = response;
      }

      return BudgetDetailDto.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ProductDTO>> getAllProducts({
    required int budgetId,
  }) async {
    try {
      debugPrint(
          '🌐 [DataSource] GET /api/orcamentos/$budgetId/produtos-completos');

      // ✅ Usar ResponseType.bytes para receber bytes crus
      // Depois fazemos decode UTF-8 MANUAL para evitar corrupção de caracteres especiais
      // Necessário porque JSON tem 114KB+ (5000+ linhas) e Dio não consegue fazer auto-parse
      final response = await apiService.get(
        '/api/orcamentos/$budgetId/produtos-completos',
        responseType: ResponseType.bytes,
      );

      // Verificar se API retornou erro
      if (response.containsKey('success') && response['success'] == false) {
        final errorMsg =
            response['error'] ?? response['message'] ?? 'Erro desconhecido';
        debugPrint('❌ [DataSource] API retornou erro: $errorMsg');
        throw Exception('Erro ao buscar produtos: $errorMsg');
      }

      // Extrair bytes da resposta
      if (!response.containsKey('data')) {
        debugPrint('❌ [DataSource] Resposta não contém dados em "data"');
        throw Exception('Resposta da API em formato inválido');
      }

      final dynamic rawData = response['data'];

      // Converter bytes para String com UTF-8 EXPLÍCITO
      String jsonString;

      if (rawData is List<int>) {
        // ✅ DECODE UTF-8 MANUAL - Garante que caracteres especiais (ê, ó, á, ã) sejam preservados
        jsonString = utf8.decode(rawData, allowMalformed: false);
        debugPrint(
            '📦 [DataSource] Bytes decodificados com UTF-8: ${jsonString.length} chars');
      } else if (rawData is String) {
        // Fallback: se já vier como string
        jsonString = rawData;
        debugPrint(
            '⚠️ [DataSource] Dados já vieram como String: ${jsonString.length} chars');
      } else {
        debugPrint(
            '❌ [DataSource] Tipo de dados inesperado: ${rawData.runtimeType}');
        throw Exception('Formato de resposta inválido');
      }

      debugPrint('🚀 [DataSource] Iniciando parse em Isolate com compute()...');

      // 🚀 Parse assíncrono em isolate para não travar a UI
      final produtos = await compute(_parseProductsInIsolate, jsonString);

      debugPrint(
          '✅ [DataSource] ${produtos.length} produtos parseados com sucesso via Isolate');

      return produtos;
    } on DioException catch (e) {
      debugPrint('❌ [DataSource] DioException: ${e.message}');
      debugPrint('   Status: ${e.response?.statusCode}');
      debugPrint('   Data: ${e.response?.data}');
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      debugPrint('❌ [DataSource] Exceção: $e');
      debugPrint('Stack: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<ProductDTO>> getCategoryProducts({
    required int budgetId,
    required int categoryId,
  }) async {
    try {
      final response = await apiService.get(
        '/api/orcamentos/$budgetId/categorias/$categoryId/produtos',
      );

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

      // Extrair array de produtos
      final produtosJson = data['produtos'] as List<dynamic>;

      // Parsear cada produto (pode usar isolate aqui também se necessário)
      final produtos = produtosJson
          .map((json) => ProductDTO.fromJson(json as Map<String, dynamic>))
          .toList();

      return produtos;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BudgetDetailDto> updateBudget({
    required int id,
    String? name,
    String? status,
    DateTime? validityDate,
    Map<String, bool>? categoryStates,
    List<int>? selectedProductIds,
  }) async {
    try {
      // Montar body da requisição
      final Map<String, dynamic> body = {};

      if (name != null && name.isNotEmpty) {
        body['nome'] = name;
      }

      if (status != null && status.isNotEmpty) {
        body['orc_status'] = status;
      }

      if (validityDate != null) {
        body['orc_data_validade'] = validityDate.toIso8601String();
      }

      if (categoryStates != null) {
        // Enviar apenas categorias ativas
        body['categorias_ativas'] = categoryStates.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();
      }

      if (selectedProductIds != null) {
        body['produtos_selecionados'] = selectedProductIds;
      }

      final response = await apiService.put('/api/orcamentos/$id', body);

      // Extrair dados da resposta - response já é Map<String, dynamic>
      final data = response['dados'] ?? response['data'] ?? response;

      return BudgetDetailDto.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BudgetDetailDto> updateBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  }) async {
    try {
      // Converter DTO para JSON (apenas campos não-nulos)
      final body = updateData.toJson();

      final response = await apiService.put('/api/orcamentos/$budgetId', body);

      // Extrair dados da resposta
      // response pode ser: {dados: {...}} ou {data: {dados: {...}}} ou {data: {...}}
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

      return BudgetDetailDto.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  /// Trata erros do Dio e lança exceções apropriadas
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
