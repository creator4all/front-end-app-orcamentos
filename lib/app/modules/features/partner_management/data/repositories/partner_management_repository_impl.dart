import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../../domain/entities/partner.dart';
import '../../domain/repositories/partner_management_repository.dart';
import '../datasources/partner_management_datasource.dart';

class PartnerManagementRepositoryImpl implements PartnerManagementRepository {
  final PartnerManagementDatasource datasource;

  PartnerManagementRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, PaginatedPartners>> listPartners({
    required int page,
    int perPage = 15,
    String? searchQuery,
    String sort = 'tradeName_asc',
  }) async {
    try {
      final result = await datasource.listPartners(
        page: page,
        perPage: perPage,
        searchQuery: searchQuery,
        sort: sort,
      );
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure('Erro ao listar parceiros: $e'));
    }
  }
}
