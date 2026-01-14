import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/partner.dart';

/// Interface abstrata do repositório de gerenciamento de parceiros
abstract class PartnerManagementRepository {
  /// Lista parceiros com paginação
  Future<Either<Failure, PaginatedPartners>> listPartners({
    required int page,
    int perPage = 15,
  });
}
