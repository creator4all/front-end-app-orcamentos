import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/budget_entity.dart';
import '../repositories/budget_list_repository.dart';

class RenameBudgetUseCase {
  final BudgetListRepository repository;

  RenameBudgetUseCase(this.repository);

  Future<Either<BudgetFailure, BudgetEntity>> call(
    int budgetId,
    String newName,
  ) async {
    if (newName.trim().isEmpty) {
      return const Left(
          ValidationFailure('O nome do orçamento não pode ser vazio'));
    }

    if (newName.trim().length < 3) {
      return const Left(
        ValidationFailure(
            'O nome do orçamento deve ter no mínimo 3 caracteres'),
      );
    }

    return await repository.renameBudget(budgetId, newName.trim());
  }
}
