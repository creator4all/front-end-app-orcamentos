import '../../domain/entities/censo_escolar_entity.dart';
import '../models/budget_census_dto.dart';
import '../models/census_data_dto.dart';

/// Interface abstrata para operações remotas de dados do Censo Escolar
abstract class CensusRemoteDataSource {
  /// Busca dados agregados do censo para uma cidade
  Future<CensusDataDto> getCensusData(int cityId);

  /// Busca dados do censo para múltiplas cidades
  Future<List<CensusDataDto>> getMultipleCitiesCensusData(List<int> cityIds);

  /// Busca o censo escolar completo (detalhado) para uma cidade
  Future<CensoEscolarEntity> getCensusByCity(int cityId);

  /// Atualiza os índices do censo escolar para uma cidade
  Future<CensoEscolarEntity> updateCensusIndices(
    int cityId,
    Map<int, double> indices,
  );

  /// Atualiza os índices do censo escolar via endpoint de orçamento
  Future<BudgetCensusDto> updateBudgetCensusIndices({
    required int budgetId,
    required int cityId,
    required Map<int, double> indices,
  });

  /// Busca dados do censo para orçamento (suporta multi-cidade)
  /// GET /api/orcamentos/{id}/censo
  Future<BudgetCensusDto> getBudgetCensus(int budgetId);
}
