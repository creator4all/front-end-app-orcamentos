import '../../../../../../shared/core/http/app_http_client.dart';
import 'indicators_remote_datasource.dart';

/// Implementação do datasource remoto para indicadores de produtos
class IndicatorsRemoteDataSourceImpl implements IndicatorsRemoteDataSource {
  final AppHttpClient _client;

  IndicatorsRemoteDataSourceImpl(this._client);

  @override
  Future<void> saveIndicators(
    int orcamentoId,
    int produtoId,
    Map<String, dynamic> requestData,
  ) async {
    print(
        '💾 [IndicatorsDataSource] Salvando indicadores do produto $produtoId no orçamento $orcamentoId');
    print('📋 [IndicatorsDataSource] Dados: $requestData');

    final response = await _client.post(
      '/api/orcamentos/$orcamentoId/produtos/$produtoId/indicadores',
      data: requestData,
    );

    print('🔍 [IndicatorsDataSource] Resposta: ${response.statusCode}');

    if (!response.isSuccess) {
      final errorMsg = response.body['mensagem'] ??
          response.body['message'] ??
          'Erro ao salvar indicadores';
      throw Exception(errorMsg);
    }

    print('✅ [IndicatorsDataSource] Indicadores salvos com sucesso');
  }
}
