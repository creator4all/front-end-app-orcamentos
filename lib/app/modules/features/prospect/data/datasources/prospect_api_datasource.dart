import '../../../../../shared/core/http/app_http_client.dart';
import '../models/prospect_dto.dart';
import 'prospect_datasource.dart';

/// Implementação do datasource usando API HTTP
class ProspectApiDatasource implements ProspectDatasource {
  final AppHttpClient httpClient;

  ProspectApiDatasource({required this.httpClient});

  @override
  Future<PaginatedProspectsDto> getProspects({
    int page = 1,
    bool? isContatado,
  }) async {
    try {
      print('📋 [ProspectApiDatasource] Listando prospects página $page...');

      // Monta a query string
      var queryParams = 'page=$page';
      if (isContatado != null) {
        queryParams += '&is_contatado=${isContatado ? 1 : 0}';
      }

      final response = await httpClient.get(
        '/api/private/prospeccao-parceiros?$queryParams',
      );

      if (response.statusCode == 200) {
        print('✅ [ProspectApiDatasource] Prospects carregados com sucesso');
        return PaginatedProspectsDto.fromJson(response.body);
      }

      throw Exception('Erro ao listar prospects: ${response.statusCode}');
    } catch (e) {
      print('❌ [ProspectApiDatasource] Erro ao listar prospects: $e');
      rethrow;
    }
  }

  @override
  Future<ProspectDto> updateProspect(int id, bool isContatado) async {
    try {
      print('📝 [ProspectApiDatasource] Atualizando prospect $id...');

      final payload = {
        'prp_is_contatado': isContatado,
      };

      final response = await httpClient.put(
        '/api/private/prospeccao-parceiros/$id',
        data: payload,
      );

      if (response.statusCode == 200) {
        print('✅ [ProspectApiDatasource] Prospect atualizado com sucesso');

        // A API pode retornar o prospect atualizado no corpo
        final data = response.body['dados'] ?? response.body;
        return ProspectDto.fromJson(data);
      }

      throw Exception('Erro ao atualizar prospect: ${response.statusCode}');
    } catch (e) {
      print('❌ [ProspectApiDatasource] Erro ao atualizar prospect: $e');
      rethrow;
    }
  }
}
