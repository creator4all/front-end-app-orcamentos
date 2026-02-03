import 'package:dartz/dartz.dart';

import '../../../../../../shared/utils/string_utils.dart';
import '../../../shared/errors/budget_failure.dart';
import '../entities/partner_entity.dart';
import '../repositories/partner_repository.dart';

class GetStandardPartnersUseCase {
  final PartnerRepository _repository;

  GetStandardPartnersUseCase(this._repository);

  Future<Either<BudgetFailure, List<PartnerEntity>>> call(
      {int? excludePartnerId}) async {
    try {
      final result = await _repository.getStandardPartners();

      return result.fold(
        (failure) => Left(failure),
        (partners) {
          final activePartners = partners.where((partner) {
            if (!partner.canReceiveBudget()) return false;
            if (excludePartnerId != null && partner.id == excludePartnerId)
              return false;
            return true;
          }).toList();

          // Ordena alfabeticamente por nome (ignorando acentos)
          activePartners.sort((a, b) => compareIgnoringAccents(a.name, b.name));

          return Right(activePartners);
        },
      );
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
