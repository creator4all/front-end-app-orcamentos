import '../models/partner_profile.dart';
import '../repositories/partner_repository.dart';

class GetPartnerUseCase {
  final PartnerRepository repository;

  GetPartnerUseCase(this.repository);

  Future<PartnerProfile> call() {
    return repository.getPartner();
  }
}
