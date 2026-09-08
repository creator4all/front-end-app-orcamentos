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
      // `PUT /api/orcamentos/{id}` valida atualização completa e responde sem
      // corpo. O registro atual é relido para preencher os campos que esta
      // operação não altera, e a estrutura de edição é buscada de novo depois
      // da gravação.
      final atual = await _buscarRegistro(id);

      final response = await _client.put(
        '/api/orcamentos/$id',
        data: {
          'orc_nome': name ?? atual['orc_nome'],
          'orc_dias_validade': validityDays ?? atual['orc_dias_validade'],
          'orc_status': status ?? atual['orc_status'],
          'orc_total': atual['orc_total'],
          'orc_usuario_id': atual['orc_usuario_id'],
          'orc_partner_destino_id': atual['orc_partner_destino_id'],
          'isArchived': isArchived ?? atual['orc_is_archived'] ?? false,
          'cidades': const <int>[],
          'indicadores': const <Map<String, dynamic>>[],
          // A sincronização de produtos exige quantidade e overrides por item,
          // que esta operação não recebe; ela é feita pelo versionamento.
          'produtos': const <Map<String, dynamic>>[],
        },
      );

      if (response.isSuccess) {
        return getBudgetForEdit(id);
      }

      throw Exception(response.body['error'] ?? 'Erro ao atualizar orçamento');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _buscarRegistro(int budgetId) async {
    final response = await _client.get('/api/orcamentos/$budgetId');

    if (!response.isSuccess) {
      throw Exception(response.body['error'] ?? 'Orçamento não encontrado');
    }

    return Map<String, dynamic>.from(response.body['dados'] as Map);
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
