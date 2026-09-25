import 'package:dartz/dartz.dart';

import '../../../../../../shared/core/constants/http_constants.dart';
import '../../../../../../shared/core/errors/api_error_message.dart';
import '../../../shared/errors/budget_failure.dart';
import '../../domain/entities/partner_entity.dart';
import '../../domain/repositories/partner_repository.dart';
import '../datasources/partner_remote_datasource.dart';

/// Implementação concreta do PartnerRepository
///
/// Coordena o DataSource e converte exceções em Failures usando Either
class PartnerRepositoryImpl implements PartnerRepository {
  final PartnerRemoteDataSource remoteDataSource;

  PartnerRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<BudgetFailure, List<PartnerEntity>>>
      getStandardPartners() async {
    try {
      final partners = await remoteDataSource.getStandardPartners();
      return Right(partners);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<BudgetFailure, PartnerEntity>> getPartnerById(
    int partnerId,
  ) async {
    try {
      final partner = await remoteDataSource.getPartnerById(partnerId);
      return Right(partner);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Mapeia exceções para Failures apropriados
  BudgetFailure _mapExceptionToFailure(Exception exception) {
    final details = exception.toString();
    final message = ApiErrorMessage.from(
      exception,
      fallback: 'Não foi possível carregar os parceiros. Tente novamente.',
    );

    if (details.contains('Sem conexão') ||
        details.contains('connectionError') ||
        details.contains('Timeout') ||
        details.contains('Tempo de conexão excedido')) {
      return ConnectionFailure(message);
    }

    if (details.contains('Não autorizado') ||
        details.contains('${HttpStatusCodes.unauthorized}') ||
        details.contains('Acesso negado') ||
        details.contains('${HttpStatusCodes.forbidden}')) {
      return UnauthorizedFailure(message);
    }

    if (details.contains('não encontrado') ||
        details.contains('${HttpStatusCodes.notFound}') ||
        details.contains('Parceiro não encontrado')) {
      return NotFoundFailure(message);
    }

    if (details.contains('Erro no servidor') ||
        details.contains('${HttpStatusCodes.internalServerError}')) {
      return ServerFailure(message);
    }

    return UnknownFailure(message);
  }
}
