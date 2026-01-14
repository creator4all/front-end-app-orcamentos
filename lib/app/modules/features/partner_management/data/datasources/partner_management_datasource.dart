import '../models/partner_dto.dart';

/// Interface abstrata para datasource de gerenciamento de parceiros
abstract class PartnerManagementDatasource {
  /// Lista parceiros com paginação
  /// GET /api/partners
  Future<PaginatedPartnersDto> listPartners({
    required int page,
    required int perPage,
  });
}
