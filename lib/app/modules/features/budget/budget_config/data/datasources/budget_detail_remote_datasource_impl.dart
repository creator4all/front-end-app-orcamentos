import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:multimidiaapp/app/shared/core/http/app_http_client.dart';
import 'package:multimidiaapp/app/shared/core/http/http_request_config.dart';
import 'package:multimidiaapp/app/shared/core/utils/token_cache.dart';

import '../../../shared/models/budget_update_dto.dart';
import '../models/budget_detail_dto.dart';
import '../models/product_dto.dart';
import 'budget_detail_remote_datasource.dart';

/// Função Top-Level para ser executada em Isolate
/// Recebe uma string JSON, decodifica e mapeia para uma lista de ProductDTO
List<ProductDTO> _parseProductsInIsolate(String jsonString) {
  try {
    final jsonResponse = jsonDecode(jsonString) as Map<String, dynamic>;

    dynamic productList;

    if (jsonResponse.containsKey('data')) {
      final data = jsonResponse['data'] as Map<String, dynamic>?;
      if (data != null && data.containsKey('dados')) {
        final dados = data['dados'] as Map<String, dynamic>?;
        if (dados != null && dados.containsKey('produtos')) {
          productList = dados['produtos'];
        }
      }
    } else if (jsonResponse.containsKey('dados')) {
      final dados = jsonResponse['dados'] as Map<String, dynamic>?;
      if (dados != null && dados.containsKey('produtos')) {
        productList = dados['produtos'];
      }
    }

    if (productList != null && productList is List) {
      return productList
          .map((json) => ProductDTO.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return [];
  } catch (e) {
    return [];
  }
}

/// Implementação concreta do BudgetDetailRemoteDataSource usando AppHttpClient
class BudgetDetailRemoteDataSourceImpl implements BudgetDetailRemoteDataSource {
  final AppHttpClient _client;

  BudgetDetailRemoteDataSourceImpl(this._client);

  HttpRequestConfig get _config => HttpRequestConfig(
        token: TokenCache.instance.getTokenOrEmpty(),
      );

  @override
  Future<BudgetDetailDto> getBudgetById(int id) async {
    try {
      final response =
          await _client.get('/api/orcamentos/$id', config: _config);

      if (response.isSuccess) {
        final rawData = response.body;
        Map<String, dynamic> data;

        if (rawData.containsKey('dados')) {
          data = rawData['dados'] as Map<String, dynamic>;
        } else if (rawData.containsKey('data')) {
          final dataField = rawData['data'];
          if (dataField is Map && dataField.containsKey('dados')) {
            data = dataField['dados'] as Map<String, dynamic>;
          } else {
            data = dataField as Map<String, dynamic>;
          }
        } else {
          data = rawData;
        }

        return BudgetDetailDto.fromJson(data);
      }

      throw Exception(response.body['error'] ?? 'Orçamento não encontrado');
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

      // Usar getBytes para receber bytes crus
      // Depois fazemos decode UTF-8 manual para preservar caracteres especiais
      final bytes = await _client.getBytes(
        '/api/orcamentos/$budgetId/produtos-completos',
        config: _config,
      );

      // Converter bytes para String com UTF-8 explícito
      final jsonString = utf8.decode(bytes, allowMalformed: false);
      debugPrint(
          '📦 [DataSource] Bytes decodificados com UTF-8: ${jsonString.length} chars');

      debugPrint('🚀 [DataSource] Iniciando parse em Isolate com compute()...');

      // Parse assíncrono em isolate para não travar a UI
      final produtos = await compute(_parseProductsInIsolate, jsonString);

      debugPrint(
          '✅ [DataSource] ${produtos.length} produtos parseados com sucesso via Isolate');

      return produtos;
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
      final response = await _client.get(
        '/api/orcamentos/$budgetId/categorias/$categoryId/produtos',
        config: _config,
      );

      if (response.isSuccess) {
        final rawData = response.body;
        Map<String, dynamic> data;

        if (rawData.containsKey('dados')) {
          data = rawData['dados'] as Map<String, dynamic>;
        } else if (rawData.containsKey('data')) {
          final dataField = rawData['data'];
          if (dataField is Map && dataField.containsKey('dados')) {
            data = dataField['dados'] as Map<String, dynamic>;
          } else {
            data = dataField as Map<String, dynamic>;
          }
        } else {
          data = rawData;
        }

        final produtosJson = data['produtos'] as List<dynamic>;
        return produtosJson
            .map((json) => ProductDTO.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw Exception(response.body['error'] ?? 'Erro ao buscar produtos');
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
        body['categorias_ativas'] = categoryStates.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();
      }

      if (selectedProductIds != null) {
        body['produtos_selecionados'] = selectedProductIds;
      }

      final response = await _client.put(
        '/api/orcamentos/$id',
        data: body,
        config: _config,
      );

      if (response.isSuccess) {
        final data =
            response.body['dados'] ?? response.body['data'] ?? response.body;
        return BudgetDetailDto.fromJson(Map<String, dynamic>.from(data as Map));
      }

      throw Exception(response.body['error'] ?? 'Erro ao atualizar orçamento');
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
      final body = updateData.toJson();

      final response = await _client.put(
        '/api/orcamentos/$budgetId',
        data: body,
        config: _config,
      );

      if (response.isSuccess) {
        final rawData = response.body;
        Map<String, dynamic> data;

        if (rawData.containsKey('dados')) {
          data = rawData['dados'] as Map<String, dynamic>;
        } else if (rawData.containsKey('data')) {
          final dataField = rawData['data'];
          if (dataField is Map && dataField.containsKey('dados')) {
            data = dataField['dados'] as Map<String, dynamic>;
          } else {
            data = dataField as Map<String, dynamic>;
          }
        } else {
          data = rawData;
        }

        return BudgetDetailDto.fromJson(data);
      }

      throw Exception(response.body['error'] ?? 'Erro ao atualizar orçamento');
    } catch (e) {
      rethrow;
    }
  }
}
