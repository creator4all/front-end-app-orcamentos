import 'package:multimidiaapp/app/shared/core/http/app_http_client.dart';

import '../../../shared/models/budget_update_dto.dart';
import '../models/budget_edit_dto.dart';
import 'budget_edit_remote_datasource.dart';

class BudgetEditRemoteDataSourceImpl implements BudgetEditRemoteDataSource {
  final AppHttpClient _client;

  BudgetEditRemoteDataSourceImpl(this._client);

  @override
  Future<BudgetEditDto> getBudgetForEdit(int id) async {
    try {
      final response = await _client.get('/api/orcamentos/novo/$id');

      if (response.isSuccess) {
        return BudgetEditDto.fromJson(response.body);
      }

      throw Exception(response.body['error'] ?? 'Orçamento não encontrado');
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

      // O `PUT` responde sem corpo; a estrutura de edição é relida.
      if (response.isSuccess) {
        return getBudgetForEdit(budgetId);
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
        response.body['error'] ?? 'Erro ao versionar orçamento multi-cidade',
      );
    } catch (e) {
      rethrow;
    }
  }
}
