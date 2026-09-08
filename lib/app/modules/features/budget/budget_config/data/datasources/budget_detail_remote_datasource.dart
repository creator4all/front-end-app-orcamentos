import '../../../shared/models/budget_update_dto.dart';
import '../models/budget_detail_dto.dart';
import '../models/product_dto.dart';

abstract class BudgetDetailRemoteDataSource {
  Future<BudgetDetailDto> getBudgetById(int id);
  Future<List<ProductDTO>> getCategoryProducts({
    required int budgetId,
    required int categoryId,
  });

  Future<BudgetDetailDto?> updateBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  });
}
