import '../models/budget_detail_dto.dart';

/// Interface abstrata para operações remotas de detalhes de orçamento
abstract class BudgetDetailRemoteDataSource {
  /// Busca detalhes de um orçamento por ID
  Future<BudgetDetailDto> getBudgetById(int id);

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
