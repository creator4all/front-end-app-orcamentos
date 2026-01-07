import 'package:dartz/dartz.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_escolar_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/shared/errors/budget_failure.dart';

import '../repositories/multi_city_budget_repository.dart';

/// Caso de uso para buscar censos de múltiplas cidades
class GetMultiCityCensusUseCase {
  final MultiCityBudgetRepository _repository;

  GetMultiCityCensusUseCase(this._repository);

  /// Busca os censos escolares para as cidades especificadas
  ///
  /// Retorna um mapa de cidadeId -> CensoEscolarEntity
  Future<Either<BudgetFailure, Map<int, CensoEscolarEntity>>> call(
    List<int> cidadeIds,
  ) async {
    if (cidadeIds.isEmpty) {
      return const Left(ValidationFailure('Selecione pelo menos uma cidade'));
    }

    return _repository.buscarCensosMultiCidade(cidadeIds);
  }
}
