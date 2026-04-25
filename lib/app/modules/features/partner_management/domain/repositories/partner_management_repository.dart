import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/partner.dart';

abstract class PartnerManagementRepository {
  Future<Either<Failure, PaginatedPartners>> listPartners({
    required int page,
    int perPage = 15,
    String? searchQuery,
    String sort = 'tradeName_asc',
  });
}
