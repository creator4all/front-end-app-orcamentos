import 'package:dartz/dartz.dart';

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
        message.contains('Parceiro não encontrado')) {
      return NotFoundFailure(message);
    }

    if (message.contains('Erro no servidor') || message.contains('500')) {
      return ServerFailure(message);
    }

    return UnknownFailure(message);
  }
}
