import 'package:dartz/dartz.dart';

import '../../../budget_config/domain/entities/product_entity.dart';
import '../../../shared/errors/budget_failure.dart';
import '../entities/budget_edit_entity.dart';

/// Contrato abstrato para operações de edição de orçamento
abstract class BudgetEditRepository {
  /// Busca os detalhes completos de um orçamento para edição (estrutura)
  Future<Either<BudgetFailure, BudgetEditEntity>> getBudgetForEdit(int id);

  /// Busca TODOS os produtos do orçamento com seus estados reais do banco
  Future<Either<BudgetFailure, List<ProductEntity>>> getAllProducts({
    required int budgetId,
  });

  /// Atualiza um orçamento existente
  Future<Either<BudgetFailure, BudgetEditEntity>> updateBudget({
    required int id,
    String? name,
    int? validityDays,
    DateTime? validityDate,
    String? status,
    bool? isArchived,
    List<int>? selectedProductIds,
  });
}
