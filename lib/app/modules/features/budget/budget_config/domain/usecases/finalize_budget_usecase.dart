import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/budget_detail_entity.dart';
import '../repositories/budget_detail_repository.dart';

/// Caso de uso para finalizar um orçamento
///
/// Converte um orçamento de status 'rascunho' para 'pendente'
class FinalizeBudgetUseCase {
  final BudgetDetailRepository repository;

  FinalizeBudgetUseCase(this.repository);

  /// Executa a finalização do orçamento
  ///
  /// Valida os dados e atualiza o status para 'pendente'
  Future<Either<BudgetFailure, BudgetDetailEntity>> call({
    required int budgetId,
    required Map<String, bool> categoryStates,
    DateTime? validityDate,
    String? name,
  }) async {
    // Validação: pelo menos uma categoria deve estar selecionada
    final hasSelectedCategory = categoryStates.values.any((value) => value);
    if (!hasSelectedCategory) {
      return const Left(
        ValidationFailure('Selecione pelo menos uma categoria'),
      );
    }

    // Validação: data de validade é obrigatória
    if (validityDate == null) {
      return const Left(
        ValidationFailure('Defina a data de validade'),
      );
    }

    // Validação: data de validade deve ser futura
    if (validityDate.isBefore(DateTime.now())) {
      return const Left(
        ValidationFailure('Data de validade deve ser futura'),
      );
    }

    // Atualiza o orçamento com status 'pendente'
    return await repository.updateBudget(
      id: budgetId,
      name: name,
      status: 'pendente',
      validityDate: validityDate,
      categoryStates: categoryStates,
    );
  }
}
