import 'dart:developer' as developer;

import 'api_service.dart';
import '../config/api_config.dart';
import '../entities/censo_entity.dart';

class CensoService {
  final ApiService _api;
  CensoService({ApiService? api}) : _api = api ?? ApiService();

  Future<CensoData> listarGruposCenso() async {
    final res = await _api.get(ApiConfig.gruposCensoEndpoint);
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
    final res = await _api.get(ApiConfig.censoPorCidadeEndpoint(cidadeId));
    if (res['success'] == true) {
      final data = res['data'] as Map<String, dynamic>;

      // Extract dados from the response
      final dados = data['dados'] as Map<String, dynamic>;

      final censoData = CensoData.fromJson(dados);
      return censoData;
    }
    throw Exception(res['error'] ?? 'Falha ao carregar censo por cidade');
  }
  
  /// Atualiza os valores dos índices de etapa para uma cidade específica
  /// 
  /// [cidadeId] é o ID da cidade
  /// [indicesEtapa] é um mapa onde a chave é o ID do índice e o valor é o novo valor do índice
  Future<bool> atualizarIndicesCidade(int cidadeId, Map<int, double> indicesEtapa, {String? token}) async {
    try {
      developer.log('Atualizando índices da cidade $cidadeId: $indicesEtapa');
      
      // Cria o payload para a API
      // O backend espera um array de objetos no formato esperado pelo CidadesService.php
      // onde cada objeto tem 'indice_etapa_id' e 'valor'
      final List<Map<String, dynamic>> indicesArray = [];
      
      indicesEtapa.forEach((id, value) {
        indicesArray.add({
          'indice_etapa_id': id,
          'valor': value
        });
      });
      
      final Map<String, dynamic> payload = {
        "indices_etapa": indicesArray,
      };
      
      developer.log('Payload final: $payload');
      
      final res = await _api.put(
        ApiConfig.censoPorCidadeEndpoint(cidadeId),
        payload,
        token: token
      );
      
      if (res['success'] == true) {
        developer.log('Índices atualizados com sucesso');
        return true;
      } else {
        developer.log('Erro ao atualizar índices: ${res['error']}');
        throw Exception(res['error'] ?? 'Falha ao atualizar índices da cidade');
      }
    } catch (e) {
      developer.log('Exceção ao atualizar índices: ${e.toString()}');
      throw Exception('Erro ao processar atualização dos índices: ${e.toString()}');
    }
  }
}
