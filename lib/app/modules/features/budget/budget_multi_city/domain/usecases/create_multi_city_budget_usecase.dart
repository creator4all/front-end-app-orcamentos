import 'package:dartz/dartz.dart';
import 'package:multimidiaapp/app/modules/features/budget/shared/errors/budget_failure.dart';

import '../repositories/multi_city_budget_repository.dart';

class CreateMultiCityBudgetUseCase {
  final MultiCityBudgetRepository _repository;

  CreateMultiCityBudgetUseCase(this._repository);

  Future<Either<BudgetFailure, Map<String, dynamic>>> call({
    required String nome,
    required int diasValidade,
    required int usuarioId,
    required List<int> cidadeIds,
    required Map<int, Map<int, double>> overridesPorCidade,
    int? partnerDestinoId,
  }) async {
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

    if (usuarioId <= 0) {
      return const Left(ValidationFailure('Usuário não autenticado'));
    }

    return _repository.criarMultiCidade(
      nome: nome.trim(),
      diasValidade: diasValidade,
      usuarioId: usuarioId,
      cidadeIds: cidadeIds,
      overridesPorCidade: overridesPorCidade,
      partnerDestinoId: partnerDestinoId,
    );
  }
}
