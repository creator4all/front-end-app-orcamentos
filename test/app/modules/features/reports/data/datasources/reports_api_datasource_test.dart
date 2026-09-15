import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/reports/data/datasources/reports_api_datasource.dart';
import 'package:multimidiaapp/app/shared/core/http/app_http_client.dart';
import 'package:multimidiaapp/app/shared/core/http/http_request_config.dart';
import 'package:multimidiaapp/app/shared/core/http/http_response.dart';

class _Client implements AppHttpClient {
  final HttpResponse Function(String, Map<String, dynamic>) respond;
  final calls = <Map<String, dynamic>>[];
  _Client(this.respond);

  @override
  Future<HttpResponse> get(String url, {HttpRequestConfig? config}) async {
    final query = config?.queryParameters ?? <String, dynamic>{};
    calls.add({'url': url, ...query});
    return respond(url, query);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

HttpResponse _page(int page, int total, {bool users = false, int size = 100}) {
  final start = (page - 1) * size;
  final count = (total - start).clamp(0, size);
  final metadata = {
    'current_page': page,
    'last_page': total == 0 ? 1 : (total / size).ceil(),
    'per_page': size,
    'total': total,
  };
  return HttpResponse(
      headers: {},
      statusCode: 200,
      body: {
        'dados': <String, dynamic>{
          if (users) 'pagination': metadata else ...metadata,
          'data': List.generate(
              count,
              (i) => <String, dynamic>{
                    if (users)
                      'usr_userId': start + i + 1
                    else
                      'id': start + i + 1,
                    if (!users) 'usuario': {'id': 7},
                    if (!users) 'created_at': '2026-09-01T10:00:00',
                  }),
        },
      });
}

void main() {
  test('carrega todos os 205 usuários em três páginas com metadata aninhada',
      () async {
    final client =
        _Client((url, query) => _page(query['page'] as int, 205, users: true));
    final rows =
        await ReportsApiDatasource(httpClient: client).getPartnerUsers(3);
    expect(rows, hasLength(205));
    expect(rows.last.id, 205);
    expect(client.calls.map((c) => c['page']), [1, 2, 3]);
    expect(client.calls.every((c) => c['per_page'] == 100), isTrue);
    expect(client.calls.first['url'], '/api/partners/3/usuarios');
    expect(client.calls.first.containsKey('data_inicio'), isFalse);
  });

  test(
      'usuário e parceiro usam orçamentos canônicos e percorrem >100 registros',
      () async {
    final client = _Client((url, query) => _page(query['page'] as int, 205));
    final source = ReportsApiDatasource(httpClient: client);
    final users = await source.getUserBudgets(7,
        dataInicio: DateTime(2026, 1, 2), dataFim: DateTime(2026, 9, 7));
    final partner = await source.getPartnerSales(3,
        dataInicio: DateTime(2026, 1, 2), dataFim: DateTime(2026, 9, 7));
    expect(users, hasLength(205));
    expect(partner, hasLength(205));
    expect(
        client.calls.every((c) =>
            c['url'] == '/api/orcamentos' &&
            c['data_inicio'] == '2026-01-02' &&
            c['data_fim'] == '2026-09-07'),
        isTrue);
    expect(client.calls[0]['orc_usuario_id'], '7');
    expect(client.calls[3]['partner_id'], '3');
    expect(client.calls.any((c) => c.containsKey('orc_status')), isFalse);
  });

  test('segue metadata mesmo quando servidor retorna 15 por página', () async {
    final client =
        _Client((url, query) => _page(query['page'] as int, 31, size: 15));
    expect(await ReportsApiDatasource(httpClient: client).getPartnerSales(3),
        hasLength(31));
    expect(client.calls.map((c) => c['page']), [1, 2, 3]);
  });

  test('sem período não inventa datas; limites isolados são enviados',
      () async {
    final client = _Client((url, query) => _page(1, 0));
    final source = ReportsApiDatasource(httpClient: client);
    await source.getUserBudgets(7);
    await source.getUserBudgets(7, dataInicio: DateTime(2026, 9, 1));
    await source.getPartnerSales(3, dataFim: DateTime(2026, 9, 7));
    expect(client.calls[0].containsKey('data_inicio'), isFalse);
    expect(client.calls[0].containsKey('data_fim'), isFalse);
    expect(client.calls[1]['data_inicio'], '2026-09-01');
    expect(client.calls[1].containsKey('data_fim'), isFalse);
    expect(client.calls[2]['data_fim'], '2026-09-07');
    expect(client.calls[2].containsKey('data_inicio'), isFalse);
  });

  test('intervalo invertido é rejeitado antes de enviar HTTP', () async {
    final client = _Client((url, query) => _page(1, 0));
    await expectLater(
        ReportsApiDatasource(httpClient: client).getUserBudgets(7,
            dataInicio: DateTime(2026, 9, 8), dataFim: DateTime(2026, 9, 7)),
        throwsFormatException);
    expect(client.calls, isEmpty);
  });

  test(
      'refina pelo autor após paginação quando visibilidade inclui outro usuário',
      () async {
    final client = _Client((url, query) {
      final response = _page(query['page'] as int, 101);
      final rows = response.body['dados']['data'] as List;
      for (final row in rows) {
        if (row['id'] != 101) row['usuario'] = {'id': 99};
      }
      return response;
    });
    final rows =
        await ReportsApiDatasource(httpClient: client).getUserBudgets(7);
    expect(rows.map((row) => row.id), [101]);
    expect(client.calls, hasLength(2));
  });

  for (final failure in [
    'http',
    'incomplete',
    'repeated',
    'metadata',
    'changed'
  ]) {
    test('falha $failure na segunda página não entrega resultado parcial',
        () async {
      final client = _Client((url, query) {
        final page = query['page'] as int;
        if (page == 1) return _page(1, 101);
        final result = _page(2, 101);
        final data = result.body['dados'] as Map<String, dynamic>;
        if (failure == 'http') return result.copyWith(statusCode: 500);
        if (failure == 'incomplete') data['data'] = [];
        if (failure == 'repeated') data['data'][0]['id'] = 1;
        if (failure == 'metadata') data['current_page'] = 1;
        if (failure == 'changed') data['total'] = 102;
        return result;
      });
      await expectLater(
          ReportsApiDatasource(httpClient: client).getPartnerSales(3),
          throwsA(anyOf(isA<FormatException>(), isA<StateError>())));
      expect(client.calls, hasLength(2));
    });
  }

  test('sem metadata rejeita lista de tamanho desconhecido', () async {
    final client = _Client((url, query) =>
        HttpResponse(headers: {}, statusCode: 200, body: {'dados': []}));
    await expectLater(
        ReportsApiDatasource(httpClient: client).getPartnerUsers(3),
        throwsFormatException);
  });
}
