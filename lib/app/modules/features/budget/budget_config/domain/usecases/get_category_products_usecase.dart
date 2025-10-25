import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/product_entity.dart';
import '../repositories/budget_detail_repository.dart';

/// Caso de uso para buscar produtos de uma categoria específica (lazy-load)
/// Utilizado quando usuário marca checkbox de categoria que ainda não tem produtos carregados
class GetCategoryProductsUseCase {
  final BudgetDetailRepository repository;

  GetCategoryProductsUseCase(this.repository);

  /// Executa o caso de uso
  /// Retorna Either<Failure, List<ProductEntity>>
  ///
  /// [budgetId] ID do orçamento
  /// [categoryId] ID da categoria para buscar produtos
  Future<Either<BudgetFailure, List<ProductEntity>>> call({
    required int budgetId,
    required int categoryId,
  }) async {
    // Validações
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
