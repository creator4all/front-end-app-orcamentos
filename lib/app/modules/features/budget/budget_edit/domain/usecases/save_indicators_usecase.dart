import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../repositories/indicators_repository.dart';

class SaveIndicatorsUseCase {
  final IndicatorsRepository repository;

  SaveIndicatorsUseCase(this.repository);

  Future<Either<BudgetFailure, Unit>> call(SaveIndicatorsParams params) async {
    if (params.orcamentoId <= 0) {
      return const Left(ValidationFailure('ID do orçamento inválido'));
    }

    if (params.produtoId <= 0) {
      return const Left(ValidationFailure('ID do produto inválido'));
    }

    return await repository.saveIndicators(params);
  }
}
