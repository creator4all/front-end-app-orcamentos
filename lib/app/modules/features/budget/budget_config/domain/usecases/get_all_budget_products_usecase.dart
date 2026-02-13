import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/product_entity.dart';
import '../repositories/budget_detail_repository.dart';

class GetAllBudgetProductsUseCase {
  final BudgetDetailRepository repository;

  GetAllBudgetProductsUseCase(this.repository);

  Future<Either<BudgetFailure, List<ProductEntity>>> call({
    required int budgetId,
  }) async {
    if (budgetId <= 0) {
      return const Left(
        ValidationFailure('ID do orçamento inválido'),
      );
    }

    return await repository.getAllProducts(budgetId: budgetId);
  }
}
