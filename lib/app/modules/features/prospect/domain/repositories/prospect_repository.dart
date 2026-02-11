import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/prospect_entity.dart';

abstract class ProspectRepository {
  Future<Either<Failure, PaginatedProspects>> getProspects({
    int page = 1,
    bool? isContatado,
  });

  Future<Either<Failure, ProspectEntity>> markAsContacted(int id);
}
