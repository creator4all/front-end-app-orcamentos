import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../../domain/entities/census_data_entity.dart';
import '../../domain/repositories/census_repository.dart';
import '../datasources/census_remote_datasource.dart';

/// Implementação concreta do CensusRepository
class CensusRepositoryImpl implements CensusRepository {
  final CensusRemoteDataSource remoteDataSource;

  CensusRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<BudgetFailure, CensusDataEntity>> getCensusData(
      int cityId) async {
    try {
      print('📦 [Repository] Buscando censo para cidade: $cityId');

      final dto = await remoteDataSource.getCensusData(cityId);
      final entity = dto.toEntity();

      print('✅ [Repository] Censo convertido para entidade');

      return Right(entity);
    } on Exception catch (e) {
      print('❌ [Repository] Erro: $e');
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<BudgetFailure, List<CensusDataEntity>>>
      getMultipleCitiesCensusData(List<int> cityIds) async {
    try {
      print('📦 [Repository] Buscando censo para ${cityIds.length} cidades');

      final dtos = await remoteDataSource.getMultipleCitiesCensusData(cityIds);
      final entities = dtos.map((dto) => dto.toEntity()).toList();

      print('✅ [Repository] ${entities.length} censos convertidos');

      return Right(entities);
    } on Exception catch (e) {
      print('❌ [Repository] Erro: $e');
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Mapeia exceções para failures
  BudgetFailure _mapExceptionToFailure(Exception exception) {
    final message = exception.toString().replaceAll('Exception: ', '');

    if (message.contains('Timeout') || message.contains('timeout')) {
      return ServerFailure(message);
    }

    if (message.contains('não encontrado') || message.contains('404')) {
      return const NotFoundFailure('Dados do censo não encontrados');
    }

    if (message.contains('Não autorizado') ||
        message.contains('401') ||
        message.contains('403')) {
      return const UnauthorizedFailure('Acesso negado');
    }

    if (message.contains('internet') || message.contains('conexão')) {
      return ConnectionFailure(message);
    }

    return UnknownFailure(message);
  }
}
