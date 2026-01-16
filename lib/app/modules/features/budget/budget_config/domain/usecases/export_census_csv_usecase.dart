import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../repositories/census_repository.dart';

/// UseCase para exportar censo escolar em formato CSV
class ExportCensusCsvUseCase {
  final CensusRepository _repository;

  ExportCensusCsvUseCase(this._repository);

  /// Exporta o censo do orçamento para CSV
  /// Retorna os bytes do arquivo CSV
  Future<Either<BudgetFailure, Uint8List>> call(int budgetId) async {
    return _repository.exportCensusCsv(budgetId);
  }
}
