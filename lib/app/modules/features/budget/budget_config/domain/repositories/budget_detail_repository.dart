import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/budget_detail_entity.dart';

/// Contrato abstrato para operações de detalhes de orçamento
abstract class BudgetDetailRepository {
  /// Busca os detalhes de um orçamento por ID
  Future<Either<BudgetFailure, BudgetDetailEntity>> getBudgetById(int id);

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
