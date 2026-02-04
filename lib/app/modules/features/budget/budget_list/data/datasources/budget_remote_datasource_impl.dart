import 'package:multimidiaapp/app/shared/core/http/app_http_client.dart';
import 'package:multimidiaapp/app/shared/core/http/http_request_config.dart';
import 'package:multimidiaapp/app/shared/core/utils/token_cache.dart';

import '../models/budget_dto.dart';
import 'budget_remote_datasource.dart';

/// Implementação concreta do BudgetRemoteDataSource usando AppHttpClient
class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  final AppHttpClient _client;

  BudgetRemoteDataSourceImpl(this._client);

  HttpRequestConfig get _config => HttpRequestConfig(
        token: TokenCache.instance.getTokenOrEmpty(),
      );

  @override
  Future<List<BudgetDto>> getBudgets({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['orc_status'] = status;
      }

      final response = await _client.get(
        '/api/orcamentos',
        config: _config.copyWith(queryParameters: queryParams),
      );

      if (response.isSuccess) {
        final data = response.body;

        // Extrair dados da resposta
        final dynamic rawData = data['dados'] ?? data['data'] ?? data;

        // Converter para lista
        final List list;
        if (rawData is Map && rawData['dados'] is List) {
          list = rawData['dados'] as List;
        } else if (rawData is List) {
          list = rawData;
        } else {
          list = [];
        }

        return list
            .map((e) => BudgetDto.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }

      throw Exception(response.body['error'] ?? 'Falha ao carregar orçamentos');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BudgetDto> getBudgetById(int budgetId) async {
    try {
      final response = await _client.get(
        '/api/orcamentos/$budgetId',
        config: _config,
      );

      if (response.isSuccess) {
        final data =
            response.body['dados'] ?? response.body['data'] ?? response.body;
        return BudgetDto.fromJson(Map<String, dynamic>.from(data as Map));
      }

      throw Exception(response.body['error'] ?? 'Orçamento não encontrado');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BudgetDto> renameBudget(int budgetId, String newName) async {
    try {
      final response = await _client.put(
        '/api/orcamentos/$budgetId',
        data: {'nome': newName},
        config: _config,
      );

      if (response.isSuccess) {
        final data =
            response.body['dados'] ?? response.body['data'] ?? response.body;
        return BudgetDto.fromJson(Map<String, dynamic>.from(data as Map));
      }

      throw Exception(response.body['error'] ?? 'Falha ao renomear orçamento');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteBudget(int budgetId) async {
    try {
      final response = await _client.delete(
        '/api/orcamentos/$budgetId',
        config: _config,
      );

      if (!response.isSuccess) {
        throw Exception(response.body['error'] ?? 'Falha ao excluir orçamento');
      }
    } catch (e) {
      rethrow;
    }
  }
}
