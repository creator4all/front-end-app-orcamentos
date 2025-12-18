/// Interface do datasource remoto para indicadores de produtos
abstract class IndicatorsRemoteDataSource {
  /// Salva indicadores de um produto em um orçamento
  ///
  /// [orcamentoId] ID do orçamento
  /// [produtoId] ID do produto
  /// [requestData] Dados da requisição com lista de indicadores
  /// Lança exceção em caso de erro
  Future<void> saveIndicators(
    int orcamentoId,
    int produtoId,
    Map<String, dynamic> requestData,
  );
}
