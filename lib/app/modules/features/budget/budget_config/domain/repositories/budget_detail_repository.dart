import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/budget_detail_entity.dart';
import '../entities/product_entity.dart';

/// Contrato abstrato para operações de detalhes de orçamento
abstract class BudgetDetailRepository {
  /// Busca os detalhes de um orçamento por ID
  Future<Either<BudgetFailure, BudgetDetailEntity>> getBudgetById(int id);

  /// Busca TODOS os produtos do orçamento (eager-load)
  /// Utilizado na inicialização para carregar todos os produtos de uma vez
  ///
  /// [budgetId] ID do orçamento
  Future<Either<BudgetFailure, List<ProductEntity>>> getAllProducts({
    required int budgetId,
  });

  /// Busca produtos completos de uma categoria específica (lazy-load)
  /// Utilizado quando usuário marca checkbox de categoria
  ///
  /// [budgetId] ID do orçamento
  /// [categoryId] ID da categoria
  Future<Either<BudgetFailure, List<ProductEntity>>> getCategoryProducts({
    required int budgetId,
    required int categoryId,
  });

  /// Atualiza um orçamento existente
  /// Utilizado para finalizar um rascunho ou editar dados
  Future<Either<BudgetFailure, BudgetDetailEntity>> updateBudget({
    required int id,
    String? name,
    String? status,
    DateTime? validityDate,
    Map<String, bool>? categoryStates,
    List<int>? selectedProductIds,
  });
}
