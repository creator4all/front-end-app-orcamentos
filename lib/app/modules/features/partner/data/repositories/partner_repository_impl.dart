import 'dart:io';

import '../../domain/models/partner_profile.dart';
import '../../domain/repositories/partner_repository.dart';
import '../services/partner_service.dart';

class PartnerRepositoryImpl implements PartnerRepository {
  final PartnerService _service;

  PartnerRepositoryImpl(this._service);

  @override
  Future<PartnerProfile> getPartner() {
    return _service.obterParceiro();
  }

  @override
  Future<PartnerProfile> updatePartner(Map<String, dynamic> data) {
    return _service.atualizarParceiro(data);
  }

  @override
  Future<PartnerProfile> uploadLogo(String filePath) {
    return _service.uploadLogo(File(filePath));
  }

  @override
  Future<List<int>> viewContract(int partnerId) {
    return _service.viewContract(partnerId);
  }
}
