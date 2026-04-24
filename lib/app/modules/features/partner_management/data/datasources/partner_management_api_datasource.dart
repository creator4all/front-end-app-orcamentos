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
    String? searchQuery,
    String sort = 'tradeName_asc',
  }) async {
    try {
      final queryParameters = {
        'page': page,
        'per_page': perPage,
        'sort': sort,
      };
      final trimmedSearchQuery = searchQuery?.trim();
      if (trimmedSearchQuery != null && trimmedSearchQuery.isNotEmpty) {
        queryParameters['q'] = trimmedSearchQuery;
      }

      final response = await httpClient.get(
        '/api/partners',
        config: HttpRequestConfig(
          queryParameters: queryParameters,
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
