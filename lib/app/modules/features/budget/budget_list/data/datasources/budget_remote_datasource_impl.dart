import 'package:multimidiaapp/app/shared/core/http/app_http_client.dart';
import 'package:multimidiaapp/app/shared/core/http/http_request_config.dart';

import '../models/budget_dto.dart';
import 'budget_remote_datasource.dart';

class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  final AppHttpClient _client;

  BudgetRemoteDataSourceImpl(this._client);

  @override
  Future<List<BudgetDto>> getBudgets({String? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null) {
      queryParams['orc_status'] = status;
    }

    final response = await _client.get(
      '/api/orcamentos',
      config: HttpRequestConfig(queryParameters: queryParams),
    );

    if (response.isSuccess) {
      final List list =
          response.body['dados'] is List ? response.body['dados'] as List : [];

      return list
          .map((e) => BudgetDto.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    throw Exception(response.body['error'] ?? 'Falha ao carregar orçamentos');
  }

  @override
  Future<BudgetDto> getBudgetById(int budgetId) async {
    final response = await _client.get('/api/orcamentos/$budgetId');

    if (response.isSuccess) {
      final data = response.body['dados'];
      return BudgetDto.fromJson(Map<String, dynamic>.from(data as Map));
    }

    throw Exception(response.body['error'] ?? 'Orçamento não encontrado');
  }

  @override
  Future<BudgetDto> renameBudget(int budgetId, String newName) async {
    // `PUT /api/orcamentos/{id}` valida atualização completa: todas as chaves
    // do schema precisam estar presentes e o corpo da resposta vem vazio. O
    // registro atual é relido para preencher os campos que a renomeação não
    // altera e para devolver o orçamento já atualizado à store.
    final atual = await _buscarRegistro(budgetId);

    final response = await _client.put(
      '/api/orcamentos/$budgetId',
      data: {
        'orc_nome': newName,
        'orc_dias_validade': atual['orc_dias_validade'],
        'orc_status': atual['orc_status'],
        'orc_total': atual['orc_total'],
        'orc_usuario_id': atual['orc_usuario_id'],
        'orc_partner_destino_id': atual['orc_partner_destino_id'],
        'isArchived': atual['orc_is_archived'] ?? false,
        'cidades': const <int>[],
        'indicadores': const <Map<String, dynamic>>[],
        'produtos': const <Map<String, dynamic>>[],
      },
    );

    if (response.isSuccess) {
      return BudgetDto.fromJson({...atual, 'orc_nome': newName});
    }

    throw Exception(response.body['error'] ?? 'Falha ao renomear orçamento');
  }

  Future<Map<String, dynamic>> _buscarRegistro(int budgetId) async {
    final response = await _client.get('/api/orcamentos/$budgetId');

    if (!response.isSuccess) {
      throw Exception(response.body['error'] ?? 'Orçamento não encontrado');
    }

    return Map<String, dynamic>.from(response.body['dados'] as Map);
  }

  @override
  Future<void> deleteBudget(int budgetId) async {
    final response = await _client.delete('/api/orcamentos/$budgetId');

    if (!response.isSuccess) {
      throw Exception(response.body['error'] ?? 'Falha ao excluir orçamento');
    }
  }
}
