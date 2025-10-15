import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/census_data_entity.dart';
import '../repositories/census_repository.dart';

/// Caso de uso para buscar dados do Censo Escolar
class GetCensusDataUseCase {
  final CensusRepository repository;

  GetCensusDataUseCase(this.repository);

  /// Executa o caso de uso para uma cidade
  /// Retorna Either<Failure, CensusDataEntity>
  Future<Either<BudgetFailure, CensusDataEntity>> call(int cityId) async {
    if (cityId <= 0) {
      return const Left(
        ValidationFailure('ID da cidade inválido'),
      );
    }

    return await repository.getCensusData(cityId);
  }

  /// Busca dados para múltiplas cidades
  Future<Either<BudgetFailure, List<CensusDataEntity>>> callMultipleCities(
    List<int> cityIds,
  ) async {
    if (cityIds.isEmpty) {
      return const Left(
        ValidationFailure('Lista de cidades vazia'),
      );
    }

    return await repository.getMultipleCitiesCensusData(cityIds);
  }
}
