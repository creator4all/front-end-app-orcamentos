import 'package:intl/intl.dart';

import '../../../../../shared/core/http/app_http_client.dart';
import '../../../../../shared/core/http/http_request_config.dart';
import '../models/report_budget_dto.dart';
import '../models/report_user_dto.dart';
import 'reports_datasource.dart';

class ReportsApiDatasource implements ReportsDatasource {
  final AppHttpClient httpClient;

  ReportsApiDatasource({required this.httpClient});

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  Map<String, dynamic> _period(DateTime? start, DateTime? end) {
    final startText = start == null ? null : _dateFormat.format(start);
    final endText = end == null ? null : _dateFormat.format(end);
    if (startText != null &&
        endText != null &&
        startText.compareTo(endText) > 0) {
      throw const FormatException(
          'A data inicial deve ser anterior ou igual à data final.');
    }
    return {
      if (startText != null) 'data_inicio': startText,
      if (endText != null) 'data_fim': endText,
    };
  }

  /// As stores calculam busca e totais sobre o conjunto completo. Só entregamos
  /// a lista após todas as páginas; falhas ou alterações na paginação invalidam
  /// a carga inteira para não apresentar totais parciais como definitivos.
  Future<List<Map<String, dynamic>>> _loadAll(
    String path, {
    required String idKey,
    Map<String, dynamic> query = const {},
  }) async {
    final rows = <Map<String, dynamic>>[];
    final ids = <int>{};
    int? expectedTotal;
    int? expectedLastPage;
    int? expectedPerPage;
    for (var page = 1;; page++) {
      final response = await httpClient.get(
        path,
        config: HttpRequestConfig(
            queryParameters: {...query, 'page': page, 'per_page': 100}),
      );
      if (!response.isSuccess) {
        throw StateError(
            'Não foi possível carregar os dados (HTTP ${response.statusCode}).');
      }
      final data = response.body['dados'];
      if (data is! Map<String, dynamic> || data['data'] is! List) {
        throw const FormatException('Resposta paginada inválida.');
      }
      final metadata = data['pagination'] ?? data;
      if (metadata is! Map<String, dynamic>) {
        throw const FormatException('Metadados de paginação ausentes.');
      }
      int readInt(String key) {
        final value = metadata[key];
        final parsed =
            value is int ? value : int.tryParse(value?.toString() ?? '');
        if (parsed == null) throw FormatException('Paginação inválida: $key.');
        return parsed;
      }

      final currentPage = readInt('current_page');
      final lastPage = readInt('last_page');
      final total = readInt('total');
      final perPage = readInt('per_page');
      if (currentPage != page ||
          total < 0 ||
          perPage < 1 ||
          lastPage < 1 ||
          lastPage != (total == 0 ? 1 : (total + perPage - 1) ~/ perPage) ||
          (expectedTotal != null && total != expectedTotal) ||
          (expectedLastPage != null && lastPage != expectedLastPage) ||
          (expectedPerPage != null && perPage != expectedPerPage)) {
        throw const FormatException(
            'A paginação mudou durante a consulta. Atualize o relatório.');
      }
      expectedTotal = total;
      expectedLastPage = lastPage;
      expectedPerPage = perPage;
      final pageRows = data['data'] as List;
      final expectedCount =
          page < lastPage ? perPage : total - (page - 1) * perPage;
      if (pageRows.length != expectedCount) {
        throw const FormatException('Página incompleta. Atualize o relatório.');
      }
      for (final row in pageRows) {
        if (row is! Map<String, dynamic>) {
          throw const FormatException('Registro inválido.');
        }
        final id = int.tryParse(row[idKey]?.toString() ?? '');
        if (id == null || id < 1 || !ids.add(id)) {
          throw const FormatException(
              'Registros repetidos ou sem identificação. Atualize o relatório.');
        }
        rows.add(row);
      }
      if (page == lastPage) return rows;
    }
  }

  @override
  Future<List<ReportUserDto>> getPartnerUsers(int partnerId,
      {DateTime? dataInicio, DateTime? dataFim}) async {
    // Usuários não têm filtro de período. O resumo cruza seus IDs com os
    // orçamentos canônicos filtrados pela data de criação.
    final rows = await _loadAll('/api/partners/$partnerId/usuarios',
        idKey: 'usr_userId');
    return rows.map(ReportUserDto.fromJson).toList();
  }

  @override
  Future<List<ReportBudgetDto>> getUserBudgets(int userId,
      {DateTime? dataInicio, DateTime? dataFim, String? status}) async {
    final rows = await _loadAll('/api/orcamentos', idKey: 'id', query: {
      'orc_usuario_id': userId.toString(),
      ..._period(dataInicio, dataFim),
      if (status != null && status.isNotEmpty) 'orc_status': status,
    });
    // A visibilidade do servidor pode ampliar o conjunto para orçamentos
    // destinados à empresa. Esta tela continua sendo do usuário selecionado.
    return rows
        .map(ReportBudgetDto.fromOrcamentoJson)
        .where((budget) => budget.usuarioId == userId)
        .toList();
  }

  @override
  Future<List<ReportBudgetDto>> getPartnerSales(int partnerId,
      {DateTime? dataInicio, DateTime? dataFim}) async {
    final rows = await _loadAll('/api/orcamentos', idKey: 'id', query: {
      'partner_id': partnerId.toString(),
      ..._period(dataInicio, dataFim),
    });
    return rows.map(ReportBudgetDto.fromOrcamentoJson).toList();
  }
}
