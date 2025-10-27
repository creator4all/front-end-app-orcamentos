import '../../../shared/models/budget_update_dto.dart';
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

  /// Atualiza um orçamento existente (Método legado)
  ///
  /// **DEPRECATED**: Use [updateBudgetWithDto] para maior flexibilidade
  @Deprecated('Use updateBudgetWithDto')
  Future<BudgetDetailDto> updateBudget({
    required int id,
    String? name,
    String? status,
    DateTime? validityDate,
    Map<String, bool>? categoryStates,
    List<int>? selectedProductIds,
  });

  /// Atualiza um orçamento usando DTO completo
  ///
  /// Endpoint: PUT /api/orcamentos/{id}
  ///
  /// [budgetId] ID do orçamento a atualizar
  /// [updateData] DTO com dados para atualização (partial update)
  ///
  /// Retorna o orçamento atualizado do backend
  Future<BudgetDetailDto> updateBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  });
}
