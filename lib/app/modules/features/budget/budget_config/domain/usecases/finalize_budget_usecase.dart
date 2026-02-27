import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/budget_detail_entity.dart';
import '../repositories/budget_detail_repository.dart';

class FinalizeBudgetUseCase {
  final BudgetDetailRepository repository;

  FinalizeBudgetUseCase(this.repository);

  Future<Either<BudgetFailure, BudgetDetailEntity>> call({
    required int budgetId,
    required Map<String, bool> categoryStates,
    DateTime? validityDate,
    String? name,
  }) async {
    final hasSelectedCategory = categoryStates.values.any((value) => value);
    if (!hasSelectedCategory) {
      return const Left(
        ValidationFailure('Selecione pelo menos uma categoria'),
      );
    }

    if (validityDate == null) {
      return const Left(
        ValidationFailure('Defina a data de validade'),
      );
    }

    if (validityDate.isBefore(DateTime.now())) {
      return const Left(
        ValidationFailure('Data de validade deve ser futura'),
      );
    }

    return await repository.updateBudget(
      id: budgetId,
      name: name,
      status: 'pendente',
      validityDate: validityDate,
      categoryStates: categoryStates,
    );
  }
}
