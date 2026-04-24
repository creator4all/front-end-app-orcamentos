import '../models/partner_dto.dart';

abstract class PartnerManagementDatasource {
  Future<PaginatedPartnersDto> listPartners({
    required int page,
    required int perPage,
    String? searchQuery,
    String sort = 'tradeName_asc',
  });
}
