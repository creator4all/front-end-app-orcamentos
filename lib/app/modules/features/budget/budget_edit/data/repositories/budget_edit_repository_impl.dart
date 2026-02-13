import 'package:dartz/dartz.dart';

import '../../../../../../shared/core/constants/http_constants.dart';
import '../../../shared/errors/budget_failure.dart';
import '../../../shared/models/budget_update_dto.dart';
import '../../domain/entities/budget_edit_entity.dart';
import '../../domain/repositories/budget_edit_repository.dart';
import '../datasources/budget_edit_remote_datasource.dart';

class BudgetEditRepositoryImpl implements BudgetEditRepository {
  final BudgetEditRemoteDataSource remoteDataSource;

  BudgetEditRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<BudgetFailure, BudgetEditEntity>> getBudgetForEdit(
    int id,
  ) async {
    try {
      final dto = await remoteDataSource.getBudgetForEdit(id);
      final entity = dto.toEntity();

      return Right(entity);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<BudgetFailure, BudgetEditEntity>> updateBudget({
    required int id,
    String? name,
    int? validityDays,
    DateTime? validityDate,
    String? status,
    bool? isArchived,
    List<int>? selectedProductIds,
  }) async {
    try {
      final dto = await remoteDataSource.updateBudget(
        id: id,
        name: name,
        validityDays: validityDays,
        validityDate: validityDate,
        status: status,
        isArchived: isArchived,
        selectedProductIds: selectedProductIds,
      );

      final entity = dto.toEntity();

      return Right(entity);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<BudgetFailure, BudgetEditEntity>> updateBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  }) async {
    try {
      final dto = await remoteDataSource.updateBudgetWithDto(
        budgetId: budgetId,
        updateData: updateData,
      );

      final entity = dto.toEntity();

      return Right(entity);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<BudgetFailure, BudgetEditEntity>> versionBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  }) async {
    try {
      final dto = await remoteDataSource.versionBudgetWithDto(
        budgetId: budgetId,
        updateData: updateData,
      );

      final entity = dto.toEntity();

      return Right(entity);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<BudgetFailure, BudgetEditEntity>>
      versionMultiCityBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  }) async {
    try {
      final dto = await remoteDataSource.versionMultiCityBudgetWithDto(
        budgetId: budgetId,
        updateData: updateData,
      );

      final entity = dto.toEntity();

      return Right(entity);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  BudgetFailure _mapExceptionToFailure(Exception exception) {
    final message = exception.toString().replaceAll('Exception: ', '');

    if (message.contains('Timeout') || message.contains('timeout')) {
      return ServerFailure(message);
    }

    if (message.contains('não encontrado') ||
        message.contains('${HttpStatusCodes.notFound}')) {
      return const NotFoundFailure('Orçamento não encontrado');
    }

    if (message.contains('Não autorizado') ||
        message.contains('${HttpStatusCodes.unauthorized}') ||
        message.contains('${HttpStatusCodes.forbidden}')) {
      return const UnauthorizedFailure('Acesso negado');
    }

    if (message.contains('internet') || message.contains('conexão')) {
      return ConnectionFailure(message);
    }

    return UnknownFailure(message);
  }
}
