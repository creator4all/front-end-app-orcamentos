import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../repositories/budget_list_repository.dart';

/// Caso de uso para excluir um orçamento
class DeleteBudgetUseCase {
  final BudgetListRepository repository;

  DeleteBudgetUseCase(this.repository);

  /// Executa o caso de uso
  ///
  /// [budgetId] - ID do orçamento
  ///
  /// Retorna [Right(unit)] em caso de sucesso
  /// Retorna [Left(BudgetFailure)] em caso de erro
  Future<Either<BudgetFailure, Unit>> call(int budgetId) async {
    return await repository.deleteBudget(budgetId);
  }
}
