import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:multimidiaapp/app/shared/core/http/app_http_client.dart';

import '../../../budget_config/data/models/product_dto.dart';
import '../../../shared/models/budget_update_dto.dart';
import '../models/budget_edit_dto.dart';
import 'budget_edit_remote_datasource.dart';

/// Função Top-Level para ser executada em Isolate
List<ProductDTO> _parseProductsInIsolate(String jsonString) {
  try {
    final jsonResponse = jsonDecode(jsonString) as Map<String, dynamic>;
    final dados = jsonResponse['dados'] as Map<String, dynamic>?;
    final productList = dados?['produtos'];

    if (productList is List) {
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

  @override
  Future<BudgetEditDto> getBudgetForEdit(int id) async {
    try {
      final response = await _client.get('/api/orcamentos/$id');

      if (response.isSuccess) {
        final data = response.body['dados'] as Map<String, dynamic>;
        return BudgetEditDto.fromJson(data);
      }

      throw Exception(response.body['error'] ?? 'Orçamento não encontrado');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getBudgetProductsComplete(int id) async {
    try {
      final bytes = await _client.getBytes(
        '/api/orcamentos/$id/produtos-completos',
      );

      final jsonString = utf8.decode(bytes, allowMalformed: false);
      final produtos = await compute(_parseProductsInIsolate, jsonString);

      return {
        'orcamento_id': id,
        'total_produtos': produtos.length,
        'produtos': produtos.map((p) => p.toJson()).toList(),
      };
    } catch (e) {
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
      );

      if (response.isSuccess) {
        final data = response.body['dados'] as Map<String, dynamic>;
        return BudgetEditDto.fromJson(data);
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
      );

      if (response.isSuccess) {
        final data = response.body['dados'] as Map<String, dynamic>;
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

      final response = await _client.post(
        '/api/orcamentos/$budgetId/versionar',
        data: body,
      );

      if (response.isSuccess) {
        final data = response.body['dados'] as Map<String, dynamic>;
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

      final response = await _client.post(
        '/api/orcamentos/$budgetId/versionar-multi-cidade',
        data: body,
      );

      if (response.isSuccess) {
        final data = response.body['dados'] as Map<String, dynamic>;
        return BudgetEditDto.fromJson(data);
      }

      throw Exception(
          response.body['error'] ?? 'Erro ao versionar orçamento multi-cidade');
    } catch (e) {
      rethrow;
    }
  }
}
