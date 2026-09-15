import '../models/partner_profile.dart';
import '../repositories/partner_repository.dart';

class UpdatePartnerUseCase {
  final PartnerRepository repository;

  UpdatePartnerUseCase(this.repository);

  Future<PartnerProfile> call(Map<String, dynamic> data) {
    return repository.updatePartner(data);
  }
}
