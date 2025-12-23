import '../../../shared/models/budget_update_dto.dart';
import '../models/budget_edit_dto.dart';

/// Interface abstrata para operações remotas de edição de orçamento
abstract class BudgetEditRemoteDataSource {
  /// Busca orçamento completo para edição (estrutura com categorias/subcategorias)
  Future<BudgetEditDto> getBudgetForEdit(int id);

  /// Busca TODOS os produtos completos do orçamento com seus estados reais do banco
  Future<Map<String, dynamic>> getBudgetProductsComplete(int id);

  /// Atualiza um orçamento (Método legado)
  ///
  /// **DEPRECATED**: Use [updateBudgetWithDto]
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

  /// Atualiza um orçamento usando DTO completo
  ///
  /// Endpoint: PUT /api/orcamentos/{id}
  ///
  /// [budgetId] ID do orçamento a atualizar
  /// [updateData] DTO com dados para atualização (partial update)
  ///
  /// Retorna o orçamento atualizado do backend
  Future<BudgetEditDto> updateBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  });

  /// Cria nova versão do orçamento com as alterações
  ///
  /// Endpoint: POST /api/orcamentos/{id}/versionar
  ///
  /// O orçamento original permanece inalterado e uma nova versão
  /// é criada com as alterações fornecidas.
  ///
  /// [budgetId] ID do orçamento a versionar
  /// [updateData] DTO com dados da nova versão
  ///
  /// Retorna a nova versão do orçamento criada
  Future<BudgetEditDto> versionBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  });
}
