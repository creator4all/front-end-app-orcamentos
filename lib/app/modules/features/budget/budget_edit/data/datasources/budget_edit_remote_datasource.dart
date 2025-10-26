import '../models/budget_edit_dto.dart';

/// Interface abstrata para operações remotas de edição de orçamento
abstract class BudgetEditRemoteDataSource {
  /// Busca orçamento completo para edição (estrutura com categorias/subcategorias)
  Future<BudgetEditDto> getBudgetForEdit(int id);

  /// Busca TODOS os produtos completos do orçamento com seus estados reais do banco
  Future<Map<String, dynamic>> getBudgetProductsComplete(int id);

  /// Atualiza um orçamento
  Future<BudgetEditDto> updateBudget({
    required int id,
    String? name,
    int? validityDays,
    DateTime? validityDate,
    String? status,
    bool? isArchived,
    List<int>? selectedProductIds,
  });
}
