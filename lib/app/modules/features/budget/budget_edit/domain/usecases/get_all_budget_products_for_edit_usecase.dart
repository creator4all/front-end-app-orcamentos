import 'package:dartz/dartz.dart';

import '../../../budget_config/domain/entities/product_entity.dart';
import '../../../shared/errors/budget_failure.dart';
import '../repositories/budget_edit_repository.dart';

/// Use case para buscar TODOS os produtos de um orçamento para edição
///
/// Retorna todos os produtos com seus estados reais do banco de dados:
/// - selecionado (true/false)
/// - quantidade
/// - observações
/// - valores
///
/// Usado para fazer merge com a estrutura de categorias/subcategorias
class GetAllBudgetProductsForEditUseCase {
  final BudgetEditRepository repository;

  GetAllBudgetProductsForEditUseCase(this.repository);

  /// Busca todos os produtos do orçamento
  ///
  /// @param budgetId - ID do orçamento
  /// @return Either com lista de ProductEntity ou BudgetFailure
  Future<Either<BudgetFailure, List<ProductEntity>>> call({
    required int budgetId,
  }) async {
    return await repository.getAllProducts(budgetId: budgetId);
  }
}
