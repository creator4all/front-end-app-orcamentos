import '../../../shared/models/budget_update_dto.dart';
import '../models/budget_edit_dto.dart';

abstract class BudgetEditRemoteDataSource {
  Future<BudgetEditDto> getBudgetForEdit(int id);

  @Deprecated('Use updateBudgetWithDto')
  Future<BudgetEditDto> updateBudget({
    required int id,
    String? name,
    int? validityDays,
    DateTime? validityDate,
    String? status,
    bool? isArchived,
    List<int>? selectedProductIds,
  });

  Future<BudgetEditDto> updateBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  });

  Future<BudgetEditDto> versionBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  });

  Future<BudgetEditDto> versionMultiCityBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  });
}
