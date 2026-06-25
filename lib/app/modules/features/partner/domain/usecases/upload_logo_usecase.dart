import '../models/partner_profile.dart';
import '../repositories/partner_repository.dart';

class UploadLogoUseCase {
  final PartnerRepository repository;

  UploadLogoUseCase(this.repository);

  Future<PartnerProfile> call(String filePath) {
    return repository.uploadLogo(filePath);
  }
}
