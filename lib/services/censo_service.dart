import 'dart:developer' as developer;

import '../app/shared/core/utils/token_cache.dart';
import '../config/api_config.dart';
import '../entities/censo_entity.dart';
import 'api_service.dart';

class CensoService {
  final ApiService _api;
  CensoService({ApiService? api}) : _api = api ?? ApiService();

  Future<CensoData> listarGruposCenso() async {
    final token = TokenCache.instance.getTokenOrEmpty();
    final res = await _api.get(ApiConfig.gruposCensoEndpoint, token: token);
    if (res['success'] == true) {
      final data = res['data'];
      if (data is Map<String, dynamic>) {
        return CensoData.fromJson(data);
      }
      if (data is List) {
        return CensoData(
            totalStudents: 0,
            censusYear: '',
            groups: data
                .map((e) => CensoGroup.fromJson(e as Map<String, dynamic>))
                .toList());
      }
    }
    throw Exception(res['error'] ?? 'Falha ao carregar grupos do censo');
  }

  Future<CensoData> censoPorCidade(int cidadeId) async {
    final token = TokenCache.instance.getTokenOrEmpty();
    final res = await _api.get(ApiConfig.censoPorCidadeEndpoint(cidadeId),
        token: token);
    if (res['success'] == true) {
      final data = res['data'] as Map<String, dynamic>;

      // Extract dados from the response
      final dados = data['dados'] as Map<String, dynamic>;

      final censoData = CensoData.fromJson(dados);
      return censoData;
    }
    throw Exception(res['error'] ?? 'Falha ao carregar censo por cidade');
  }

  /// Busca censo agregado de múltiplas cidades
  /// Retorna a soma dos valores de cada indicador por cidade
  Future<Map<String, dynamic>> buscarCensoAgregado(List<int> cidadeIds) async {
    developer
        .log('📊 Buscando censo agregado para ${cidadeIds.length} cidades...');

    // Montar query params: cidades[]=1&cidades[]=2&cidades[]=3
    final queryParams = cidadeIds.map((id) => 'cidades[]=$id').join('&');
    final endpoint = '${ApiConfig.baseUrl}/api/censo/agregado?$queryParams';

    developer.log('🌐 Endpoint: $endpoint');

    final token = TokenCache.instance.getTokenOrEmpty();
    final res = await _api.get(endpoint, token: token);

    developer.log('📡 Resposta censo agregado: $res');

    if (res['success'] == true) {
      final data = res['data'];

      // Extrair dados da estrutura aninhada
      dynamic dados;
      if (data is Map && data['dados'] != null) {
        dados = data['dados'];
      } else {
        dados = data;
      }

      developer.log('🔍 Dados extraídos: $dados');

      if (dados is! Map<String, dynamic>) {
        throw Exception('Formato de resposta inválido');
      }

      return dados as Map<String, dynamic>;
    }

    throw Exception(res['error'] ?? 'Falha ao carregar censo agregado');
  }

  /// Atualiza os valores dos índices de etapa para uma cidade específica
  ///
  /// [cidadeId] é o ID da cidade
  /// [indicesEtapa] é um mapa onde a chave é o ID do índice e o valor é o novo valor do índice
  Future<bool> atualizarIndicesCidade(
      int cidadeId, Map<int, double> indicesEtapa) async {
    final token = TokenCache.instance.getTokenOrEmpty();
    try {
      developer.log('Atualizando índices da cidade $cidadeId: $indicesEtapa');

      // Cria o payload para a API
      // O backend espera um array de objetos no formato esperado pelo CidadesService.php
      // onde cada objeto tem 'indice_etapa_id' e 'valor'
      final List<Map<String, dynamic>> indicesArray = [];

      indicesEtapa.forEach((id, value) {
        indicesArray.add({'indice_etapa_id': id, 'valor': value});
      });

      final Map<String, dynamic> payload = {
        "indices_etapa": indicesArray,
      };

      developer.log('Payload final: $payload');

      final res = await _api.put(
          ApiConfig.censoPorCidadeEndpoint(cidadeId), payload,
          token: token);

      if (res['success'] == true) {
        developer.log('Índices atualizados com sucesso');
        return true;
      } else {
        developer.log('Erro ao atualizar índices: ${res['error']}');
        throw Exception(res['error'] ?? 'Falha ao atualizar índices da cidade');
      }
    } catch (e) {
      developer.log('Exceção ao atualizar índices: ${e.toString()}');
      throw Exception(
          'Erro ao processar atualização dos índices: ${e.toString()}');
    }
  }
}
