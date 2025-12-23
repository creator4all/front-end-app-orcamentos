import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/censo_escolar_entity.dart';
import '../entities/census_data_entity.dart';

/// Contrato abstrato para operações de dados do Censo Escolar
abstract class CensusRepository {
  /// Busca dados agregados do censo escolar para uma cidade
  Future<Either<BudgetFailure, CensusDataEntity>> getCensusData(int cityId);

  /// Busca dados do censo para múltiplas cidades
  Future<Either<BudgetFailure, List<CensusDataEntity>>>
      getMultipleCitiesCensusData(
    List<int> cityIds,
  );

  /// Busca o censo escolar completo (detalhado) para uma cidade
  Future<Either<BudgetFailure, CensoEscolarEntity>> getCensusByCity(int cityId);

  /// Atualiza os índices do censo escolar para uma cidade
  Future<Either<BudgetFailure, CensoEscolarEntity>> updateCensusIndices(
    int cityId,
    Map<int, double> updatedIndices,
  );

  /// Atualiza os índices do censo escolar via endpoint de orçamento
  Future<Either<BudgetFailure, CensoEscolarEntity>> updateBudgetCensusIndices({
    required int budgetId,
    required int cityId,
    required Map<int, double> updatedIndices,
  });
}
