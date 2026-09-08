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

      // O `PUT` responde apenas com status de sucesso, sem corpo: a store
      // mantém o estado local já atualizado.
      if (response.isSuccess) {
        return null;
      }

      throw Exception(response.body['error'] ?? 'Erro ao atualizar orçamento');
    } catch (e) {
      rethrow;
    }
  }
}
