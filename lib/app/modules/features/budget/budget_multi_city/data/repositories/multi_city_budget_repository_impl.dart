import 'package:dartz/dartz.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_escolar_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/shared/errors/budget_failure.dart';

import '../../domain/repositories/multi_city_budget_repository.dart';
import '../datasources/multi_city_budget_remote_datasource.dart';

/// Implementação concreta do repositório multi-cidades
class MultiCityBudgetRepositoryImpl implements MultiCityBudgetRepository {
  final MultiCityBudgetRemoteDataSource _dataSource;

  MultiCityBudgetRepositoryImpl(this._dataSource);

  @override
  Future<Either<BudgetFailure, Map<int, CensoEscolarEntity>>>
      buscarCensosMultiCidade(List<int> cidadeIds) async {
    try {
      final result = await _dataSource.buscarCensosMultiCidade(cidadeIds);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<BudgetFailure, Map<String, dynamic>>> criarMultiCidade({
    required String nome,
    required int diasValidade,
    required int usuarioId,
    required List<int> cidadeIds,
    required Map<int, Map<int, double>> overridesPorCidade,
    int? partnerDestinoId,
  }) async {
    try {
      final result = await _dataSource.criarMultiCidade(
        nome: nome,
        diasValidade: diasValidade,
        usuarioId: usuarioId,
        cidadeIds: cidadeIds,
        overridesPorCidade: overridesPorCidade,
        partnerDestinoId: partnerDestinoId,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
