import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/product_entity.dart';
import '../repositories/budget_detail_repository.dart';

/// Caso de uso para buscar TODOS os produtos de um orçamento (eager-load)
/// Utilizado na inicialização da tela para carregar todos os produtos de uma vez
/// Com no máximo 300 produtos por orçamento, é mais eficiente que lazy-load
class GetAllBudgetProductsUseCase {
  final BudgetDetailRepository repository;

  GetAllBudgetProductsUseCase(this.repository);

  /// Executa o caso de uso
  /// Retorna Either<Failure, List<ProductEntity>>
  ///
  /// [budgetId] ID do orçamento
  Future<Either<BudgetFailure, List<ProductEntity>>> call({
    required int budgetId,
  }) async {
    // Validação
    if (budgetId <= 0) {
      return const Left(
        ValidationFailure('ID do orçamento inválido'),
      );
    }

    return await repository.getAllProducts(budgetId: budgetId);
  }
}
