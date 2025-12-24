import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../../domain/entities/prospect_entity.dart';
import '../../domain/repositories/prospect_repository.dart';
import '../datasources/prospect_datasource.dart';

/// Implementação concreta do repositório de prospecção
class ProspectRepositoryImpl implements ProspectRepository {
  final ProspectDatasource datasource;

  ProspectRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, PaginatedProspects>> getProspects({
    int page = 1,
    bool? isContatado,
  }) async {
    try {
      final result = await datasource.getProspects(
        page: page,
        isContatado: isContatado,
      );
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure('Erro ao carregar prospects: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ProspectEntity>> markAsContacted(int id) async {
    try {
      final result = await datasource.updateProspect(id, true);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(
          'Erro ao marcar prospect como contactado: ${e.toString()}'));
    }
  }
}
