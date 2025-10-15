import '../../data/models/budget_dto.dart';

/// Interface para fonte de dados remota de orçamentos
///
/// Define os métodos que serão implementados para comunicação com a API
abstract class BudgetRemoteDataSource {
  /// Busca lista de orçamentos da API
  ///
  /// [status] - Filtro opcional por status
  ///
  /// Throws [ServerException] em caso de erro
  Future<List<BudgetDto>> getBudgets({String? status});

  /// Busca um orçamento específico por ID
  ///
  /// [budgetId] - ID do orçamento
  ///
  /// Throws [ServerException] ou [NotFoundException] em caso de erro
  Future<BudgetDto> getBudgetById(int budgetId);

  /// Renomeia um orçamento
  ///
  /// [budgetId] - ID do orçamento
  /// [newName] - Novo nome
  ///
  /// Throws [ServerException] em caso de erro
  Future<BudgetDto> renameBudget(int budgetId, String newName);

  /// Exclui um orçamento
  ///
  /// [budgetId] - ID do orçamento
  ///
  /// Throws [ServerException] em caso de erro
  Future<void> deleteBudget(int budgetId);
}
