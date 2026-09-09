import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/budget_entity.dart';

/// Contrato abstrato do repositório de orçamentos (Budget List)
///
/// Define as operações disponíveis sem se preocupar com a implementação.
/// A camada de domínio depende apenas desta interface.
abstract class BudgetListRepository {
  /// Lista todos os orçamentos com filtro opcional de status
  ///
  /// [status] - Status para filtrar (ex: 'pendente', 'aprovado', 'arquivado')
  ///
  /// Retorna [Right(List<BudgetEntity>)] em caso de sucesso
  /// Retorna [Left(BudgetFailure)] em caso de erro
  Future<Either<BudgetFailure, PaginatedBudgets>> getBudgets({
    String? status,
    int page = 1,
    int perPage = 15,
  });

  /// Busca um orçamento específico por ID
  ///
  /// [budgetId] - ID do orçamento
  ///
  /// Retorna [Right(BudgetEntity)] em caso de sucesso
  /// Retorna [Left(BudgetFailure)] em caso de erro
  Future<Either<BudgetFailure, BudgetEntity>> getBudgetById(int budgetId);

  /// Renomeia um orçamento
  ///
  /// [budgetId] - ID do orçamento
  /// [newName] - Novo nome do orçamento
  ///
  /// Retorna [Right(BudgetEntity)] com orçamento atualizado em caso de sucesso
  /// Retorna [Left(BudgetFailure)] em caso de erro
  Future<Either<BudgetFailure, BudgetEntity>> renameBudget(
    int budgetId,
    String newName,
  );

  /// Exclui um orçamento
  ///
  /// [budgetId] - ID do orçamento
  ///
  /// Retorna [Right(unit)] em caso de sucesso
  /// Retorna [Left(BudgetFailure)] em caso de erro
  Future<Either<BudgetFailure, Unit>> deleteBudget(int budgetId);
}
