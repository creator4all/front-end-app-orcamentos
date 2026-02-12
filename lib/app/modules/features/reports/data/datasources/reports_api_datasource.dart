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

  /// Extrai a lista de dados do response.
  ///
  /// Suporta duas estruturas:
  /// - Paginada: `{ dados: { data: [...] } }` (endpoint de usuários)
  /// - Lista direta: `{ dados: [...] }` (endpoints de orçamentos e vendas)
  List<dynamic> _extractList(dynamic body) {
    if (body is! Map<String, dynamic>) {
      throw FormatException(
          'Resposta inválida: esperado Map, recebido ${body.runtimeType}');
    }

    final dados = body['dados'];

    if (dados is Map<String, dynamic> && dados['data'] is List) {
      return dados['data'] as List<dynamic>;
    }

    if (dados is List) {
      return dados;
    }

    throw FormatException('Estrutura de resposta inesperada: ${body.keys}');
  }

  @override
  Future<List<ReportBudgetDto>> getUserBudgets(
    int userId, {
    DateTime? dataInicio,
    DateTime? dataFim,
    String? status,
  }) async {
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

    final response = await httpClient.get(
      '/api/orcamentos',
      config: HttpRequestConfig(queryParameters: queryParams),
    );

    final List<dynamic> data = _extractList(response.body);

    return data.map((json) => ReportBudgetDto.fromOrcamentoJson(json)).toList();
  }

  @override
  Future<List<ReportBudgetDto>> getPartnerSales(
    int partnerId, {
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    final queryParams = <String, dynamic>{};
    if (dataInicio != null) {
      queryParams['data_inicio'] = _dateFormat.format(dataInicio);
    }
    if (dataFim != null) {
      queryParams['data_fim'] = _dateFormat.format(dataFim);
    }

    final response = await httpClient.get(
      '/api/relatorios/partners/$partnerId/vendas',
      config: HttpRequestConfig(queryParameters: queryParams),
    );

    final List<dynamic> data = _extractList(response.body);

    return data.map((json) => ReportBudgetDto.fromVendasJson(json)).toList();
  }
}
