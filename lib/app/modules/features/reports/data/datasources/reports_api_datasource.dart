import 'package:intl/intl.dart';

import '../../../../../shared/core/http/app_http_client.dart';
import '../../../../../shared/core/http/http_request_config.dart';
import '../models/report_budget_dto.dart';
import '../models/report_user_dto.dart';
import 'reports_datasource.dart';

/// Implementação do datasource de relatórios que acessa a API.
///
/// Utiliza [AppHttpClient] para realizar as requisições HTTP com
/// interceptors de autenticação já configurados.
class ReportsApiDatasource implements ReportsDatasource {
  final AppHttpClient httpClient;

  ReportsApiDatasource({required this.httpClient});

  /// Formato de data para enviar nas requisições
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Future<List<ReportUserDto>> getPartnerUsers(
    int partnerId, {
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    // Montar query parameters
    final queryParams = <String, dynamic>{};
    if (dataInicio != null) {
      queryParams['dataInicio'] = _dateFormat.format(dataInicio);
    }
    if (dataFim != null) {
      queryParams['dataFim'] = _dateFormat.format(dataFim);
    }

    // Endpoint correto: /api/partners/{id}/usuarios
    final response = await httpClient.get(
      '/api/partners/$partnerId/usuarios',
      config: HttpRequestConfig(queryParameters: queryParams),
    );

    // Extrair lista de usuários da resposta
    // Estrutura: { dados: { data: [...] } } ou { data: [...] } ou [...]
    final List<dynamic> data = _extractList(response.body);

    return data.map((json) => ReportUserDto.fromJson(json)).toList();
  }

  /// Extrai a lista de dados do response, tratando diferentes estruturas
  List<dynamic> _extractList(dynamic body) {
    if (body is List) {
      return body;
    }

    if (body is Map<String, dynamic>) {
      // Estrutura: { dados: { data: [...] } }
      if (body['dados'] is Map<String, dynamic>) {
        final dados = body['dados'] as Map<String, dynamic>;
        if (dados['data'] is List) {
          return dados['data'] as List<dynamic>;
        }
      }

      // Estrutura: { data: [...] }
      if (body['data'] is List) {
        return body['data'] as List<dynamic>;
      }

      // Estrutura: { dados: [...] }
      if (body['dados'] is List) {
        return body['dados'] as List<dynamic>;
      }

      // Estrutura: { usuarios: [...] }
      if (body['usuarios'] is List) {
        return body['usuarios'] as List<dynamic>;
      }

      // Estrutura: { orcamentos: [...] }
      if (body['orcamentos'] is List) {
        return body['orcamentos'] as List<dynamic>;
      }
    }

    return [];
  }

  @override
  Future<List<ReportBudgetDto>> getUserBudgets(
    int userId, {
    DateTime? dataInicio,
    DateTime? dataFim,
    String? status,
  }) async {
    // Montar query parameters
    final queryParams = <String, dynamic>{};
    queryParams['usuario_id'] = userId.toString();
    if (dataInicio != null) {
      queryParams['dataInicio'] = _dateFormat.format(dataInicio);
    }
    if (dataFim != null) {
      queryParams['dataFim'] = _dateFormat.format(dataFim);
    }
    if (status != null && status.isNotEmpty) {
      queryParams['orc_status'] = status;
    }

    // Endpoint correto: /api/orcamentos com filtro de usuário
    final response = await httpClient.get(
      '/api/orcamentos',
      config: HttpRequestConfig(queryParameters: queryParams),
    );

    // Extrair lista de orçamentos usando helper
    final List<dynamic> data = _extractList(response.body);

    return data.map((json) => ReportBudgetDto.fromJson(json)).toList();
  }
}
