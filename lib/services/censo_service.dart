import 'dart:developer' as developer;

import '../app/shared/core/http/app_http_client.dart';
import '../app/shared/core/http/http_request_config.dart';
import '../app/shared/core/utils/token_cache.dart';
import '../config/api_config.dart';
import '../entities/censo_entity.dart';

class CensoService {
  final AppHttpClient _client;

  CensoService({required AppHttpClient client}) : _client = client;

  Future<CensoData> listarGruposCenso() async {
    final token = TokenCache.instance.getTokenOrEmpty();
    final response = await _client.get(
      ApiConfig.gruposCensoEndpoint,
      config: HttpRequestConfig(token: token),
    );

    if (response.isSuccess) {
      final data = response.body;

      if (data.containsKey('grupos') || data.containsKey('groups')) {
        return CensoData.fromJson(data);
      }

      if (data.containsKey('dados')) {
        final dados = data['dados'];
        if (dados is Map<String, dynamic>) {
          return CensoData.fromJson(dados);
        }
        if (dados is List) {
          return CensoData(
            totalStudents: 0,
            censusYear: '',
            groups: dados
                .map((e) => CensoGroup.fromJson(e as Map<String, dynamic>))
                .toList(),
          );
        }
      }

      // Fallback: tentar parsear diretamente
      return CensoData.fromJson(data);
    }
    throw Exception(
        response.body['error'] ?? 'Falha ao carregar grupos do censo');
  }

  Future<CensoData> censoPorCidade(int cidadeId) async {
    final token = TokenCache.instance.getTokenOrEmpty();
    final response = await _client.get(
      ApiConfig.censoPorCidadeEndpoint(cidadeId),
      config: HttpRequestConfig(token: token),
    );

    if (response.isSuccess) {
      final data = response.body;
      final dados = data['dados'];
      if (dados is Map<String, dynamic>) {
        return CensoData.fromJson(dados);
      }
      throw Exception('Formato de resposta inválido');
    }
    throw Exception(
        response.body['error'] ?? 'Falha ao carregar censo por cidade');
  }

  Future<Map<String, dynamic>> buscarCensoAgregado(List<int> cidadeIds) async {
    final queryParams = cidadeIds.map((id) => 'cidades[]=$id').join('&');
    final endpoint = '${ApiConfig.baseUrl}/api/censo/agregado?$queryParams';

    final token = TokenCache.instance.getTokenOrEmpty();
    final response = await _client.get(
      endpoint,
      config: HttpRequestConfig(token: token),
    );

    if (response.isSuccess) {
      final data = response.body;

      Map<String, dynamic> dados;
      if (data['dados'] != null && data['dados'] is Map<String, dynamic>) {
        dados = data['dados'];
      } else {
        dados = data;
      }

      return dados;
    }

    throw Exception(
        response.body['error'] ?? 'Falha ao carregar censo agregado');
  }

  Future<bool> atualizarIndicesCidade(
      int cidadeId, Map<int, double> indicesEtapa) async {
    final token = TokenCache.instance.getTokenOrEmpty();
    try {

      final List<Map<String, dynamic>> indicesArray = [];
      indicesEtapa.forEach((id, value) {
        indicesArray.add({'indice_etapa_id': id, 'valor': value});
      });

      final Map<String, dynamic> payload = {
        'indices_etapa': indicesArray,
      };

      final response = await _client.put(
        ApiConfig.censoPorCidadeEndpoint(cidadeId),
        data: payload,
        config: HttpRequestConfig(token: token),
      );

      if (response.isSuccess) {
        return true;
      } else {
        throw Exception(
            response.body['error'] ?? 'Falha ao atualizar índices da cidade');
      }
    } catch (e) {
      throw Exception(
          'Erro ao processar atualização dos índices: ${e.toString()}');
    }
  }
}
