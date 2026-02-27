import '../../domain/entities/budget_draft_entity.dart';
import '../../domain/repositories/budget_draft_repository.dart';

/// Interface abstrata para fonte de dados remota de Orçamentos em Rascunho
abstract class BudgetDraftRemoteDataSource {
  /// Cria um novo orçamento em rascunho
  Future<BudgetDraftEntity> createDraft(CreateBudgetDraftParams params);

  /// Busca um orçamento em rascunho por ID
  Future<BudgetDraftEntity> getDraftById(int budgetId);
}
