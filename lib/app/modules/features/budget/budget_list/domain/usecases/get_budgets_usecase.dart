import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/budget_entity.dart';
import '../repositories/budget_list_repository.dart';

/// Caso de uso para buscar lista de orçamentos
///
/// Encapsula a lógica de negócio para listagem de orçamentos
class GetBudgetsUseCase {
  final BudgetListRepository repository;

  GetBudgetsUseCase(this.repository);

  /// Executa o caso de uso
  ///
  /// [status] - Filtro opcional por status
  ///
  /// Retorna [Right(List<BudgetEntity>)] em caso de sucesso
  /// Retorna [Left(BudgetFailure)] em caso de erro
  Future<Either<BudgetFailure, List<BudgetEntity>>> call({
    String? status,
  }) async {
    return await repository.getBudgets(status: status);
  }
}
