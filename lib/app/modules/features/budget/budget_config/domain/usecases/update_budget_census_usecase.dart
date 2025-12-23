import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/censo_escolar_entity.dart';
import '../repositories/census_repository.dart';

/// UseCase para atualização de censo escolar via endpoint de orçamento
class UpdateBudgetCensusUseCase {
  final CensusRepository repository;

  UpdateBudgetCensusUseCase(this.repository);

  Future<Either<BudgetFailure, CensoEscolarEntity>> call({
    required int budgetId,
    required int cityId,
    required Map<int, double> indices,
  }) {
    return repository.updateBudgetCensusIndices(
      budgetId: budgetId,
      cityId: cityId,
      updatedIndices: indices,
    );
  }
}
