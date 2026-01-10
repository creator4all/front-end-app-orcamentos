import 'package:dartz/dartz.dart';
import 'package:multimidiaapp/app/modules/features/budget/shared/errors/budget_failure.dart';

import '../repositories/multi_city_budget_repository.dart';

/// Caso de uso para criar orçamento multi-cidades
class CreateMultiCityBudgetUseCase {
  final MultiCityBudgetRepository _repository;

  CreateMultiCityBudgetUseCase(this._repository);

  /// Executa a criação do orçamento multi-cidades
  ///
  /// Retorna os dados completos do orçamento criado (categorias, cidades, censo_agregado)
  Future<Either<BudgetFailure, Map<String, dynamic>>> call({
    required String nome,
    required int diasValidade,
    required List<int> cidadeIds,
    required Map<int, Map<int, double>> overridesPorCidade,
    int? partnerDestinoId,
  }) async {
    // Validações
    if (nome.trim().isEmpty) {
      return const Left(ValidationFailure('Nome do orçamento é obrigatório'));
    }

    if (cidadeIds.isEmpty) {
      return const Left(ValidationFailure('Selecione pelo menos uma cidade'));
    }

    if (diasValidade < 1 || diasValidade > 365) {
      return const Left(
          ValidationFailure('Dias de validade deve ser entre 1 e 365'));
    }

    return _repository.criarMultiCidade(
      nome: nome.trim(),
      diasValidade: diasValidade,
      cidadeIds: cidadeIds,
      overridesPorCidade: overridesPorCidade,
      partnerDestinoId: partnerDestinoId,
    );
  }
}
