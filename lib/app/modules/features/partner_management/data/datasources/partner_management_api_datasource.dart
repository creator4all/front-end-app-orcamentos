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
      final queryParameters = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        ..._sortToQuery(sort),
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

  /// Traduz o `sort` interno (`<campo>_<direcao>`) para os parâmetros
  /// `order_by`/`order_direction` aceitos por `GET /api/partners`.
  static Map<String, String> _sortToQuery(String sort) {
    final separator = sort.lastIndexOf('_');
    if (separator <= 0 || separator == sort.length - 1) return const {};

    return {
      'order_by': sort.substring(0, separator),
      'order_direction': sort.substring(separator + 1),
    };
  }
}
