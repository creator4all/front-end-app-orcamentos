import '../../../../../shared/core/http/app_http_client.dart';
import '../models/prospect_dto.dart';
import 'prospect_datasource.dart';

class ProspectApiDatasource implements ProspectDatasource {
  final AppHttpClient httpClient;

  ProspectApiDatasource({required this.httpClient});

  @override
  Future<PaginatedProspectsDto> getProspects({
    int page = 1,
    bool? isContatado,
  }) async {
    try {
      var queryParams = 'page=$page';
      if (isContatado != null) {
        queryParams += '&is_contatado=${isContatado ? 1 : 0}';
      }

      final response = await httpClient.get(
        '/api/private/prospeccao-parceiros?$queryParams',
      );

      if (response.statusCode == 200) {
        return PaginatedProspectsDto.fromJson(response.body);
      }

      throw Exception('Erro ao listar prospects: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProspectDto> updateProspect(int id, bool isContatado) async {
    try {
      final payload = {
        'prp_is_contatado': isContatado,
      };

      final response = await httpClient.put(
        '/api/private/prospeccao-parceiros/$id',
        data: payload,
      );

      if (response.statusCode == 200) {
        final data = response.body['dados'];
        return ProspectDto.fromJson(data);
      }

      throw Exception('Erro ao atualizar prospect: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}
