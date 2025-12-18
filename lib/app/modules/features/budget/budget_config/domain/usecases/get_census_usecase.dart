import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/censo_escolar_entity.dart';
import '../repositories/census_repository.dart';

class GetCensusUseCase {
  final CensusRepository repository;

  GetCensusUseCase(this.repository);

  Future<Either<BudgetFailure, CensoEscolarEntity>> call(int cityId) {
    return repository.getCensusByCity(cityId);
  }
}
