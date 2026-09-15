import 'package:dartz/dartz.dart';

import '../../../../../../shared/core/constants/http_constants.dart';
import '../../../../../../shared/core/errors/api_error_message.dart';
import '../../../../../../shared/errors/http_exception.dart';
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

  /// Mapeia exceções para Failures apropriados
  ///
  /// Usa o statusCode do HttpException para mapeamento preciso
  BudgetFailure _mapExceptionToFailure(Object exception) {
    if (exception is HttpException) {
      switch (exception.statusCode) {
        case HttpStatusCodes.unauthorized:
        case HttpStatusCodes.forbidden:
          return UnauthorizedFailure(exception.message);
        case HttpStatusCodes.notFound:
          return NotFoundFailure(exception.message);
        case HttpStatusCodes.unprocessableEntity:
          return ValidationFailure(exception.message);
        // Erros 5xx podem trazer detalhes técnicos (ex.: SQL); nunca exibi-los.
        case >= HttpStatusCodes.internalServerError:
          return const ServerFailure(ApiErrorMessage.serverFailure);
        default:
          return ServerFailure(
              'Erro ${exception.statusCode}: ${exception.message}');
      }
    }

    final message = exception.toString();

    if (message.contains('SocketException') ||
        message.contains('TimeoutException') ||
        message.contains('connectionError')) {
      return ConnectionFailure(message);
    }

    return UnknownFailure(message);
  }
}
