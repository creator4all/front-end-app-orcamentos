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
    final response = await _client.put(
      '/api/orcamentos/$budgetId',
      data: {'nome': newName},
    );

    if (response.isSuccess) {
      final data = response.body['dados'];
      return BudgetDto.fromJson(Map<String, dynamic>.from(data as Map));
    }

    throw Exception(response.body['error'] ?? 'Falha ao renomear orçamento');
  }

  @override
  Future<void> deleteBudget(int budgetId) async {
    final response = await _client.delete('/api/orcamentos/$budgetId');

    if (!response.isSuccess) {
      throw Exception(response.body['error'] ?? 'Falha ao excluir orçamento');
    }
  }
}
