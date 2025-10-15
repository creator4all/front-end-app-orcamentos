import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../../domain/entities/budget_draft_entity.dart';
import '../../domain/repositories/budget_draft_repository.dart';
import '../datasources/budget_draft_remote_datasource.dart';

/// Implementação concreta do BudgetDraftRepository
///
/// Coordena o DataSource e converte exceções em Failures usando Either
class BudgetDraftRepositoryImpl implements BudgetDraftRepository {
  final BudgetDraftRemoteDataSource remoteDataSource;

  BudgetDraftRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<BudgetFailure, BudgetDraftEntity>> createDraft(
    CreateBudgetDraftParams params,
  ) async {
    try {
      final draft = await remoteDataSource.createDraft(params);
      return Right(draft);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<BudgetFailure, BudgetDraftEntity>> getDraftById(
    int budgetId,
  ) async {
    try {
      final draft = await remoteDataSource.getDraftById(budgetId);
      return Right(draft);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<BudgetFailure, bool>> validateBudgetCreation(
    CreateBudgetDraftParams params,
  ) async {
    try {
      final isValid = await remoteDataSource.validateBudgetCreation(params);
      return Right(isValid);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Mapeia exceções para Failures apropriados
  BudgetFailure _mapExceptionToFailure(Exception exception) {
    final message = exception.toString();

    if (message.contains('Sem conexão') ||
        message.contains('connectionError') ||
        message.contains('Timeout') ||
        message.contains('Tempo de conexão excedido')) {
      return ConnectionFailure(message);
    }

    if (message.contains('Não autorizado') ||
        message.contains('401') ||
        message.contains('Acesso negado') ||
        message.contains('403')) {
      return UnauthorizedFailure(message);
    }

    if (message.contains('não encontrado') ||
        message.contains('404') ||
        message.contains('Orçamento não encontrado')) {
      return NotFoundFailure(message);
    }

    if (message.contains('Dados inválidos') ||
        message.contains('422') ||
        message.contains('validação')) {
      return ValidationFailure(message);
    }

    if (message.contains('Erro no servidor') || message.contains('500')) {
      return ServerFailure(message);
    }

    return UnknownFailure(message);
  }
}
