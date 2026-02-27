import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/budget_detail_entity.dart';
import '../repositories/budget_detail_repository.dart';

/// Caso de uso para buscar detalhes de um orçamento
class GetBudgetDetailUseCase {
  final BudgetDetailRepository repository;

  GetBudgetDetailUseCase(this.repository);

  /// Executa o caso de uso
  /// Retorna Either<Failure, BudgetDetailEntity>
  Future<Either<BudgetFailure, BudgetDetailEntity>> call(int budgetId) async {
    if (budgetId <= 0) {
      return const Left(
        ValidationFailure('ID do orçamento inválido'),
      );
    }

    return await repository.getBudgetById(budgetId);
  }
}
