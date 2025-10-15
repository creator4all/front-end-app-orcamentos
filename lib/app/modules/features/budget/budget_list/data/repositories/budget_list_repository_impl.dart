import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_list_repository.dart';
import '../datasources/budget_remote_datasource.dart';

/// Implementação concreta do BudgetListRepository
///
/// Coordena o DataSource e converte exceções em Failures usando Either
class BudgetListRepositoryImpl implements BudgetListRepository {
  final BudgetRemoteDataSource remoteDataSource;

  BudgetListRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<BudgetFailure, List<BudgetEntity>>> getBudgets({
    String? status,
  }) async {
    try {
      final budgetsDto = await remoteDataSource.getBudgets(status: status);
      final budgetsEntity = budgetsDto.map((dto) => dto.toEntity()).toList();
      return Right(budgetsEntity);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<BudgetFailure, BudgetEntity>> getBudgetById(
    int budgetId,
  ) async {
    try {
      final budgetDto = await remoteDataSource.getBudgetById(budgetId);
      return Right(budgetDto.toEntity());
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<BudgetFailure, BudgetEntity>> renameBudget(
    int budgetId,
    String newName,
  ) async {
    try {
      final budgetDto = await remoteDataSource.renameBudget(budgetId, newName);
      return Right(budgetDto.toEntity());
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<BudgetFailure, Unit>> deleteBudget(int budgetId) async {
    try {
      await remoteDataSource.deleteBudget(budgetId);
      return const Right(unit);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Mapeia exceções para Failures apropriados
  BudgetFailure _mapExceptionToFailure(Exception exception) {
    final message = exception.toString();

    if (message.contains('Sem conexão') ||
        message.contains('connectionError') ||
        message.contains('Timeout')) {
      return ConnectionFailure(message);
    }

    if (message.contains('Não autorizado') ||
        message.contains('401') ||
        message.contains('403')) {
      return UnauthorizedFailure(message);
    }

    if (message.contains('não encontrado') || message.contains('404')) {
      return NotFoundFailure(message);
    }

    if (message.contains('Erro no servidor') || message.contains('500')) {
      return ServerFailure(message);
    }

    return UnknownFailure(message);
  }
}
