import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../../../shared/models/budget_update_dto.dart';
import '../entities/budget_edit_entity.dart';

abstract class BudgetEditRepository {
  Future<Either<BudgetFailure, BudgetEditEntity>> getBudgetForEdit(int id);

  @Deprecated('Use updateBudgetWithDto')
  Future<Either<BudgetFailure, BudgetEditEntity>> updateBudget({
    required int id,
    String? name,
    int? validityDays,
    DateTime? validityDate,
    String? status,
    bool? isArchived,
    List<int>? selectedProductIds,
  });

  Future<Either<BudgetFailure, BudgetEditEntity>> updateBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  });

  Future<Either<BudgetFailure, BudgetEditEntity>> versionBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  });
  Future<Either<BudgetFailure, BudgetEditEntity>> versionMultiCityBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  });
}
