import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../../domain/entities/budget_census_entity.dart';
import '../../domain/entities/censo_escolar_entity.dart';
import '../../domain/entities/census_data_entity.dart';
import '../../domain/repositories/census_repository.dart';
import '../datasources/census_remote_datasource.dart';

class CensusRepositoryImpl implements CensusRepository {
  final CensusRemoteDataSource datasource;

  CensusRepositoryImpl(this.datasource);

  @override
  Future<Either<BudgetFailure, CensusDataEntity>> getCensusData(
      int cityId) async {
    try {
      final result = await datasource.getCensusData(cityId);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<BudgetFailure, CensoEscolarEntity>> getCensusByCity(
      int cityId) async {
    try {
      final result = await datasource.getCensusByCity(cityId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<BudgetFailure, List<CensusDataEntity>>>
      getMultipleCitiesCensusData(List<int> cityIds) async {
    try {
      final result = await datasource.getMultipleCitiesCensusData(cityIds);
      return Right(result.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<BudgetFailure, CensoEscolarEntity>> updateCensusIndices(
      int cityId, Map<int, double> updatedIndices) async {
    try {
      final result =
          await datasource.updateCensusIndices(cityId, updatedIndices);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<BudgetFailure, BudgetCensusEntity>> updateBudgetCensusIndices({
    required int budgetId,
    required int cityId,
    required Map<int, double> updatedIndices,
  }) async {
    try {
      final result = await datasource.updateBudgetCensusIndices(
        budgetId: budgetId,
        cityId: cityId,
        indices: updatedIndices,
      );
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<BudgetFailure, Uint8List>> exportCensusCsv(int budgetId) async {
    try {
      final result = await datasource.exportCensusCsv(budgetId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
