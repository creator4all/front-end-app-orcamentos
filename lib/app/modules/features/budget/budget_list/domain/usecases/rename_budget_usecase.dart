import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/budget_entity.dart';
import '../repositories/budget_list_repository.dart';

/// Caso de uso para renomear um orçamento
class RenameBudgetUseCase {
  final BudgetListRepository repository;

  RenameBudgetUseCase(this.repository);

  /// Executa o caso de uso
  ///
  /// [budgetId] - ID do orçamento
  /// [newName] - Novo nome do orçamento
  ///
  /// Retorna [Right(BudgetEntity)] com orçamento atualizado em caso de sucesso
  /// Retorna [Left(BudgetFailure)] em caso de erro
  Future<Either<BudgetFailure, BudgetEntity>> call(
    int budgetId,
    String newName,
  ) async {
    // Validação de negócio: nome não pode ser vazio
    if (newName.trim().isEmpty) {
      return const Left(
          ValidationFailure('O nome do orçamento não pode ser vazio'));
    }

    // Validação de negócio: nome deve ter no mínimo 3 caracteres
    if (newName.trim().length < 3) {
      return const Left(
        ValidationFailure(
            'O nome do orçamento deve ter no mínimo 3 caracteres'),
      );
    }

    return await repository.renameBudget(budgetId, newName.trim());
  }
}
