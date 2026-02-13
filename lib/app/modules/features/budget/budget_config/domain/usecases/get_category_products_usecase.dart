import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/product_entity.dart';
import '../repositories/budget_detail_repository.dart';

class GetCategoryProductsUseCase {
  final BudgetDetailRepository repository;

  GetCategoryProductsUseCase(this.repository);

  Future<Either<BudgetFailure, List<ProductEntity>>> call({
    required int budgetId,
    required int categoryId,
  }) async {
    if (budgetId <= 0) {
      return const Left(
        ValidationFailure('ID do orçamento inválido'),
      );
    }

    if (categoryId <= 0) {
      return const Left(
        ValidationFailure('ID da categoria inválido'),
      );
    }

    return await repository.getCategoryProducts(
      budgetId: budgetId,
      categoryId: categoryId,
    );
  }
}
