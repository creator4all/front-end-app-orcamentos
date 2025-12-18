import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../repositories/indicators_repository.dart';

/// Caso de uso para salvar indicadores de um produto em um orçamento
class SaveIndicatorsUseCase {
  final IndicatorsRepository repository;

  SaveIndicatorsUseCase(this.repository);

  /// Executa o salvamento dos indicadores
  ///
  /// [params] Parâmetros com orcamentoId, produtoId e lista de indicadores
  /// Retorna [Unit] em caso de sucesso ou [BudgetFailure] em caso de erro
  Future<Either<BudgetFailure, Unit>> call(SaveIndicatorsParams params) async {
    // Validações
    if (params.orcamentoId <= 0) {
      return const Left(ValidationFailure('ID do orçamento inválido'));
    }

    if (params.produtoId <= 0) {
      return const Left(ValidationFailure('ID do produto inválido'));
    }

    return await repository.saveIndicators(params);
  }
}
