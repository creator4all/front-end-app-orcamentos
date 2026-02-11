import '../../../../../shared/core/http/app_http_client.dart';
import '../../../../../shared/core/http/http_request_config.dart';
import '../models/partner_dto.dart';
import 'partner_management_datasource.dart';

class PartnerManagementApiDatasource implements PartnerManagementDatasource {
  final AppHttpClient httpClient;

  PartnerManagementApiDatasource({required this.httpClient});

  @override
  Future<PaginatedPartnersDto> listPartners({
    required int page,
    required int perPage,
  }) async {
    try {
      final response = await httpClient.get(
        '/api/partners',
        config: HttpRequestConfig(
          queryParameters: {'page': page, 'per_page': perPage},
        ),
      );

      if (response.statusCode == 200) {
        return PaginatedPartnersDto.fromJson(response.body);
      }

      throw Exception('Erro ao listar parceiros: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}
