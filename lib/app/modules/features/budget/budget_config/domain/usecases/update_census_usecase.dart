import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/censo_escolar_entity.dart';
import '../repositories/census_repository.dart';

class UpdateCensusUseCase {
  final CensusRepository repository;

  UpdateCensusUseCase(this.repository);

  Future<Either<BudgetFailure, CensoEscolarEntity>> call({
    required int cityId,
    required Map<int, double> indices,
  }) {
    return repository.updateCensusIndices(cityId, indices);
  }
}
