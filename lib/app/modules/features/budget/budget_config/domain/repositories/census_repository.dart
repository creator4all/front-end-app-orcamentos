import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
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
}
