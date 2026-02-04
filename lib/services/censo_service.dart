import 'dart:developer' as developer;

import '../app/shared/core/http/app_http_client.dart';
import '../app/shared/core/http/http_request_config.dart';
import '../app/shared/core/utils/token_cache.dart';
import '../config/api_config.dart';
import '../entities/censo_entity.dart';

/// Serviço de censo escolar usando AppHttpClient
///
/// Centraliza operações de consulta e atualização de dados censitários.
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

      // Response.body já é um Map<String, dynamic>
      // Verificar se contém os campos esperados de CensoData
      if (data.containsKey('grupos') || data.containsKey('groups')) {
        return CensoData.fromJson(data);
      }

      // Se contém 'dados', extrair de dentro
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

  /// Busca censo agregado de múltiplas cidades
  Future<Map<String, dynamic>> buscarCensoAgregado(List<int> cidadeIds) async {
    developer
        .log('📊 Buscando censo agregado para ${cidadeIds.length} cidades...');

    final queryParams = cidadeIds.map((id) => 'cidades[]=$id').join('&');
    final endpoint = '${ApiConfig.baseUrl}/api/censo/agregado?$queryParams';

    developer.log('🌐 Endpoint: $endpoint');

    final token = TokenCache.instance.getTokenOrEmpty();
    final response = await _client.get(
      endpoint,
      config: HttpRequestConfig(token: token),
    );

    developer.log('📡 Resposta censo agregado: ${response.body}');

    if (response.isSuccess) {
      final data = response.body;

      Map<String, dynamic> dados;
      if (data['dados'] != null && data['dados'] is Map<String, dynamic>) {
        dados = data['dados'];
      } else {
        dados = data;
      }

      developer.log('🔍 Dados extraídos: $dados');
      return dados;
    }

    throw Exception(
        response.body['error'] ?? 'Falha ao carregar censo agregado');
  }

  /// Atualiza os valores dos índices de etapa para uma cidade específica
  Future<bool> atualizarIndicesCidade(
      int cidadeId, Map<int, double> indicesEtapa) async {
    final token = TokenCache.instance.getTokenOrEmpty();
    try {
      developer.log('Atualizando índices da cidade $cidadeId: $indicesEtapa');

      final List<Map<String, dynamic>> indicesArray = [];
      indicesEtapa.forEach((id, value) {
        indicesArray.add({'indice_etapa_id': id, 'valor': value});
      });

      final Map<String, dynamic> payload = {
        'indices_etapa': indicesArray,
      };

      developer.log('Payload final: $payload');

      final response = await _client.put(
        ApiConfig.censoPorCidadeEndpoint(cidadeId),
        data: payload,
        config: HttpRequestConfig(token: token),
      );

      if (response.isSuccess) {
        developer.log('Índices atualizados com sucesso');
        return true;
      } else {
        developer.log('Erro ao atualizar índices: ${response.body['error']}');
        throw Exception(
            response.body['error'] ?? 'Falha ao atualizar índices da cidade');
      }
    } catch (e) {
      developer.log('Exceção ao atualizar índices: ${e.toString()}');
      throw Exception(
          'Erro ao processar atualização dos índices: ${e.toString()}');
    }
  }
}
