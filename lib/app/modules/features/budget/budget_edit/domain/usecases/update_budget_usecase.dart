import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/budget_edit_entity.dart';
import '../repositories/budget_edit_repository.dart';

/// Caso de uso para atualizar um orçamento
class UpdateBudgetUseCase {
  final BudgetEditRepository repository;

  UpdateBudgetUseCase(this.repository);

  Future<Either<BudgetFailure, BudgetEditEntity>> call({
    required int budgetId,
    String? name,
    int? validityDays,
    DateTime? validityDate,
    String? status,
    bool? isArchived,
    List<int>? selectedProductIds,
  }) async {
    // Validações
    if (budgetId <= 0) {
      return const Left(ValidationFailure('ID do orçamento inválido'));
    }

    if (validityDays != null && (validityDays < 1 || validityDays > 365)) {
      return const Left(
        ValidationFailure('Validade deve estar entre 1 e 365 dias'),
      );
    }

    if (validityDate != null && validityDate.isBefore(DateTime.now())) {
      return const Left(
        ValidationFailure('Data de validade não pode ser no passado'),
      );
    }

    return await repository.updateBudget(
      id: budgetId,
      name: name,
      validityDays: validityDays,
      validityDate: validityDate,
      status: status,
      isArchived: isArchived,
      selectedProductIds: selectedProductIds,
    );
  }
}
