import '../../../shared/models/budget_update_dto.dart';
import '../models/budget_edit_dto.dart';

abstract class BudgetEditRemoteDataSource {
  Future<BudgetEditDto> getBudgetForEdit(int id);

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
