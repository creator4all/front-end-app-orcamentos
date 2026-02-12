import '../../../../../../shared/core/http/app_http_client.dart';
import 'indicators_remote_datasource.dart';

class IndicatorsRemoteDataSourceImpl implements IndicatorsRemoteDataSource {
  final AppHttpClient _client;

  IndicatorsRemoteDataSourceImpl(this._client);

  @override
  Future<void> saveIndicators(
    int orcamentoId,
    int produtoId,
    Map<String, dynamic> requestData,
  ) async {
    final response = await _client.post(
      '/api/orcamentos/$orcamentoId/produtos/$produtoId/indicadores',
      data: requestData,
    );

    if (!response.isSuccess) {
      final errorMsg = response.body['mensagem'] ??
          response.body['message'] ??
          'Erro ao salvar indicadores';
      throw Exception(errorMsg);
    }
  }
}
