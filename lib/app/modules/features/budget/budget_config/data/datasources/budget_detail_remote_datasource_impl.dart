import 'package:multimidiaapp/app/shared/core/http/app_http_client.dart';
import 'package:multimidiaapp/app/shared/core/http/http_request_config.dart';
import 'package:multimidiaapp/app/shared/core/utils/token_cache.dart';

import '../../../shared/models/budget_update_dto.dart';
import '../models/budget_detail_dto.dart';
import '../models/product_dto.dart';
import 'budget_detail_remote_datasource.dart';

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
        final data = response.body['dados'] as Map<String, dynamic>;
        return BudgetDetailDto.fromJson(data);
      }

      throw Exception(response.body['error'] ?? 'Orçamento não encontrado');
    } catch (e) {
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
        final data = response.body['dados'] as Map<String, dynamic>;
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
        final data = response.body['dados'] as Map<String, dynamic>;
        return BudgetDetailDto.fromJson(data);
      }

      throw Exception(response.body['error'] ?? 'Erro ao atualizar orçamento');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BudgetDetailDto?> updateBudgetWithDto({
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
        final dados = response.body['dados'];
        if (dados is! Map<String, dynamic>) {
          // Backend pode responder apenas com status de sucesso (sem corpo).
          return null;
        }
        return BudgetDetailDto.fromJson(dados);
      }

      throw Exception(response.body['error'] ?? 'Erro ao atualizar orçamento');
    } catch (e) {
      rethrow;
    }
  }
}
