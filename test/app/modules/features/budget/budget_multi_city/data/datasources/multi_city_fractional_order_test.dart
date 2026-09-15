import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_multi_city/data/datasources/multi_city_budget_remote_datasource_impl.dart';
import 'package:multimidiaapp/app/shared/core/http/app_http_client.dart';
import 'package:multimidiaapp/app/shared/core/http/http_request_config.dart';
import 'package:multimidiaapp/app/shared/core/http/http_response.dart';

class _CensusClient implements AppHttpClient {
  final Map<String, dynamic> data;
  _CensusClient(this.data);

  @override
  Future<HttpResponse> get(String url, {HttpRequestConfig? config}) async =>
      HttpResponse(body: {'dados': data}, headers: {}, statusCode: 200);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final groupOrder in [false, true]) {
    test(
        'censo multi-cidade preserva ordem de ${groupOrder ? 'grupos' : 'etapas'}',
        () async {
      final client = _CensusClient({
        'id': 1,
        'indices_etapa': List.generate(
            40,
            (i) => {
                  'indice_etapa_id': 40 - i,
                  'nome_etapa': 'etapa$i',
                  'ind_ordem': '9999999999.${(99999960 + i)}',
                  'grupo': {
                    'grupo_id': groupOrder ? 40 - i : 1,
                    'grupo_ordem':
                        groupOrder ? '9999999999.${(99999960 + i)}' : '1',
                  },
                }),
      });
      final result = await MultiCityBudgetRemoteDataSourceImpl(client)
          .buscarCensosMultiCidade([1]);
      final census = result[1]!;
      expect(census.grupos.expand((g) => g.titulos).map((t) => t.id),
          List.generate(40, (i) => 40 - i));
      expect(census.grupos.last.titulos.last.ordem.toJson(),
          '9999999999.99999999');
    });
  }
}
