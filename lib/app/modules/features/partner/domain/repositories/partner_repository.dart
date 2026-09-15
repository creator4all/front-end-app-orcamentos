import '../../domain/models/partner_profile.dart';

abstract class PartnerRepository {
  Future<PartnerProfile> getPartner();

  Future<PartnerProfile> updatePartner(Map<String, dynamic> data);

  Future<PartnerProfile> uploadLogo(String filePath);

  Future<List<int>> viewContract(int partnerId);
}
