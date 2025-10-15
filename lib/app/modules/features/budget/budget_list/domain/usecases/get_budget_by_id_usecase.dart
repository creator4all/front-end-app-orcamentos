import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/budget_entity.dart';
import '../repositories/budget_list_repository.dart';

/// Caso de uso para buscar um orçamento específico por ID
class GetBudgetByIdUseCase {
  final BudgetListRepository repository;

  GetBudgetByIdUseCase(this.repository);

  /// Executa o caso de uso
  ///
  /// [budgetId] - ID do orçamento
  ///
  /// Retorna [Right(BudgetEntity)] em caso de sucesso
  /// Retorna [Left(BudgetFailure)] em caso de erro
  Future<Either<BudgetFailure, BudgetEntity>> call(int budgetId) async {
    return await repository.getBudgetById(budgetId);
  }
}
