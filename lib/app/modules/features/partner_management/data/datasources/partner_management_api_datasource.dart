import '../../../../../shared/core/http/app_http_client.dart';
import '../models/partner_dto.dart';
import 'partner_management_datasource.dart';

/// Implementação do datasource usando API HTTP
class PartnerManagementApiDatasource implements PartnerManagementDatasource {
  final AppHttpClient httpClient;

  PartnerManagementApiDatasource({required this.httpClient});

  @override
  Future<PaginatedPartnersDto> listPartners({
    required int page,
    required int perPage,
  }) async {
    try {
      print(
          '📋 [PartnerManagementApiDatasource] Listando parceiros página $page...');

      final response = await httpClient.get(
        '/api/partners?page=$page&per_page=$perPage',
      );

      if (response.statusCode == 200) {
        print(
            '✅ [PartnerManagementApiDatasource] Parceiros carregados com sucesso');
        return PaginatedPartnersDto.fromJson(response.body);
      }

      throw Exception('Erro ao listar parceiros: ${response.statusCode}');
    } catch (e) {
      print('❌ [PartnerManagementApiDatasource] Erro ao listar parceiros: $e');
      rethrow;
    }
  }
}
