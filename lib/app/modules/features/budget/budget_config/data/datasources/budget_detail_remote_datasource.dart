import '../models/budget_detail_dto.dart';
import '../models/product_dto.dart';

/// Interface abstrata para operações remotas de detalhes de orçamento
abstract class BudgetDetailRemoteDataSource {
  /// Busca detalhes de um orçamento por ID
  Future<BudgetDetailDto> getBudgetById(int id);

  /// Busca TODOS os produtos do orçamento (eager-load)
  ///
  /// [budgetId] ID do orçamento
  Future<List<ProductDTO>> getAllProducts({
    required int budgetId,
  });

  /// Busca produtos completos de uma categoria específica (lazy-load)
  ///
  /// [budgetId] ID do orçamento
  /// [categoryId] ID da categoria
  Future<List<ProductDTO>> getCategoryProducts({
    required int budgetId,
    required int categoryId,
  });

  /// Atualiza um orçamento existente
  Future<BudgetDetailDto> updateBudget({
    required int id,
    String? name,
    String? status,
    DateTime? validityDate,
    Map<String, bool>? categoryStates,
    List<int>? selectedProductIds,
  });
}
