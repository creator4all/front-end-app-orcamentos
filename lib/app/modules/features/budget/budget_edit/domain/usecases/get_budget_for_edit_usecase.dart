import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/budget_edit_entity.dart';
import '../repositories/budget_edit_repository.dart';

/// Caso de uso para buscar orçamento para edição
class GetBudgetForEditUseCase {
  final BudgetEditRepository repository;

  GetBudgetForEditUseCase(this.repository);

  Future<Either<BudgetFailure, BudgetEditEntity>> call(int budgetId) async {
    if (budgetId <= 0) {
      return const Left(
        ValidationFailure('ID do orçamento inválido'),
      );
    }

    return await repository.getBudgetForEdit(budgetId);
  }
}
