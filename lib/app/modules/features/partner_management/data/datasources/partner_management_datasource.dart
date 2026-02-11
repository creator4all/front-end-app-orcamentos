import '../models/partner_dto.dart';

abstract class PartnerManagementDatasource {
  Future<PaginatedPartnersDto> listPartners({
    required int page,
    required int perPage,
  });
}
