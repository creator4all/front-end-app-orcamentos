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
      // `PUT /api/private/prospeccao-parceiros/{id}` valida atualização
      // completa: todas as chaves do schema precisam estar presentes. Como a
      // tela só altera o flag de contato, os demais campos são relidos do
      // próprio registro antes do envio.
      final atual = await _buscarPorId(id);

      final response = await httpClient.put(
        '/api/private/prospeccao-parceiros/$id',
        data: {
          'prp_nome': atual.prpNome,
          'prp_email': atual.prpEmail,
          'prp_telefone': atual.prpTelefone,
          'prp_empresa': atual.prpEmpresa,
          'prp_documento': atual.prpDocumento,
          'prp_experiencia_vendas_publicas': atual.prpExperienciaVendasPublicas,
          'prp_is_contatado': isContatado,
        },
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

  Future<ProspectDto> _buscarPorId(int id) async {
    final response = await httpClient.get(
      '/api/private/prospeccao-parceiros/$id',
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar prospect: ${response.statusCode}');
    }

    return ProspectDto.fromJson(response.body['dados']);
  }
}
