import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../../../shared/models/budget_update_dto.dart';
import '../entities/budget_detail_entity.dart';
import '../entities/product_entity.dart';

abstract class BudgetDetailRepository {
  Future<Either<BudgetFailure, BudgetDetailEntity>> getBudgetById(int id);

  Future<Either<BudgetFailure, List<ProductEntity>>> getCategoryProducts({
    required int budgetId,
    required int categoryId,
  });
  @Deprecated('Use updateBudgetWithDto para maior flexibilidade')
  Future<Either<BudgetFailure, BudgetDetailEntity>> updateBudget({
    required int id,
    String? name,
    String? status,
    DateTime? validityDate,
    Map<String, bool>? categoryStates,
    List<int>? selectedProductIds,
  });

  Future<Either<BudgetFailure, BudgetDetailEntity>> updateBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  });
}
