import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/partner.dart';
import '../repositories/partner_management_repository.dart';

/// Caso de uso para listar parceiros
class ListPartnersUsecase {
  final PartnerManagementRepository repository;

  ListPartnersUsecase(this.repository);

  /// Executa o caso de uso
  Future<Either<Failure, PaginatedPartners>> call({
    required int page,
    int perPage = 15,
  }) {
    return repository.listPartners(page: page, perPage: perPage);
  }
}
