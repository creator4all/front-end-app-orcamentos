import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:multimidiaapp/app/shared/core/http/app_http_client.dart';
import 'package:multimidiaapp/app/shared/core/http/http_request_config.dart';
import 'package:multimidiaapp/app/shared/core/utils/token_cache.dart';

import '../../../budget_config/data/models/product_dto.dart';
import '../../../shared/models/budget_update_dto.dart';
import '../models/budget_edit_dto.dart';
import 'budget_edit_remote_datasource.dart';

/// Função Top-Level para ser executada em Isolate
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

class BudgetEditRemoteDataSourceImpl implements BudgetEditRemoteDataSource {
  final AppHttpClient _client;

  BudgetEditRemoteDataSourceImpl(this._client);

  HttpRequestConfig get _config => HttpRequestConfig(
        token: TokenCache.instance.getTokenOrEmpty(),
      );

  Map<String, dynamic> _extractData(Map<String, dynamic> response) {
    if (response.containsKey('dados')) {
      return response['dados'] as Map<String, dynamic>;
    } else if (response.containsKey('data')) {
      final dataField = response['data'];
      if (dataField is Map && dataField.containsKey('dados')) {
        return dataField['dados'] as Map<String, dynamic>;
      } else {
        return dataField as Map<String, dynamic>;
      }
    }
    return response;
  }

  @override
  Future<BudgetEditDto> getBudgetForEdit(int id) async {
    try {
      final response =
          await _client.get('/api/orcamentos/$id', config: _config);

      if (response.isSuccess) {
        final data = _extractData(response.body);
        return BudgetEditDto.fromJson(Map<String, dynamic>.from(data));
      }

      throw Exception(response.body['error'] ?? 'Orçamento não encontrado');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getBudgetProductsComplete(int id) async {
    try {
      debugPrint(
        '🌐 [BudgetEdit-DataSource] GET /api/orcamentos/$id/produtos-completos',
      );

      // Usar getBytes para receber bytes crus
      final bytes = await _client.getBytes(
        '/api/orcamentos/$id/produtos-completos',
        config: _config,
      );

      // Converter bytes para String com UTF-8 explícito
      final jsonString = utf8.decode(bytes, allowMalformed: false);
      debugPrint(
        '📦 [BudgetEdit-DataSource] Bytes decodificados com UTF-8: ${jsonString.length} chars',
      );

      debugPrint(
        '🚀 [BudgetEdit-DataSource] Iniciando parse em Isolate com compute()...',
      );

      // Parse assíncrono em isolate para não travar a UI
      final produtos = await compute(_parseProductsInIsolate, jsonString);

      debugPrint(
        '✅ [BudgetEdit-DataSource] ${produtos.length} produtos parseados com sucesso via Isolate',
      );

      return {
        'orcamento_id': id,
        'total_produtos': produtos.length,
        'produtos': produtos.map((p) => p.toJson()).toList(),
      };
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

      final response = await _client.put(
        '/api/orcamentos/$id',
        data: body,
        config: _config,
      );

      if (response.isSuccess) {
        final data = _extractData(response.body);
        return BudgetEditDto.fromJson(Map<String, dynamic>.from(data));
      }

      throw Exception(response.body['error'] ?? 'Erro ao atualizar orçamento');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BudgetEditDto> updateBudgetWithDto({
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
        final data = _extractData(response.body);
        return BudgetEditDto.fromJson(data);
      }

      throw Exception(response.body['error'] ?? 'Erro ao atualizar orçamento');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BudgetEditDto> versionBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  }) async {
    try {
      final body = updateData.toJson();

      debugPrint(
        '🔄 [BudgetEdit-DataSource] POST /api/orcamentos/$budgetId/versionar',
      );
      debugPrint('📦 [BudgetEdit-DataSource] Payload: $body');

      final response = await _client.post(
        '/api/orcamentos/$budgetId/versionar',
        data: body,
        config: _config,
      );

      if (response.isSuccess) {
        final data = _extractData(response.body);
        debugPrint('✅ [BudgetEdit-DataSource] Nova versão criada com sucesso');
        return BudgetEditDto.fromJson(data);
      }

      throw Exception(response.body['error'] ?? 'Erro ao versionar orçamento');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BudgetEditDto> versionMultiCityBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  }) async {
    try {
      final body = updateData.toJsonForMultiCity();

      debugPrint(
        '🔄 [BudgetEdit-DataSource] POST /api/orcamentos/$budgetId/versionar-multi-cidade',
      );
      debugPrint('📦 [BudgetEdit-DataSource] Payload: $body');

      final response = await _client.post(
        '/api/orcamentos/$budgetId/versionar-multi-cidade',
        data: body,
        config: _config,
      );

      if (response.isSuccess) {
        final data = _extractData(response.body);
        debugPrint(
          '✅ [BudgetEdit-DataSource] Nova versão multi-cidade criada com sucesso',
        );
        return BudgetEditDto.fromJson(data);
      }

      throw Exception(
          response.body['error'] ?? 'Erro ao versionar orçamento multi-cidade');
    } catch (e) {
      rethrow;
    }
  }
}
