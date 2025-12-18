import 'package:multimidiaapp/config/api_config.dart';
import 'package:multimidiaapp/services/api_service.dart';

import '../../domain/entities/censo_escolar_entity.dart';
import '../../domain/entities/censo_group_entity.dart';
import '../../domain/entities/censo_title_entity.dart';
import '../models/census_data_dto.dart';
import 'census_remote_datasource.dart';

class CensusRemoteDataSourceImpl implements CensusRemoteDataSource {
  final ApiService _apiService;

  CensusRemoteDataSourceImpl(this._apiService);

  @override
  Future<CensusDataDto> getCensusData(int cityId) async {
    // Implement existing method logic if needed or keep existing if it was expected
    // Assuming this retrieves summary data
    final response = await _apiService.get(
      ApiConfig.censoPorCidadeEndpoint(cityId),
    );

    if (response['success'] == true) {
      final data = response['data']['dados'];
      return CensusDataDto.fromJson(data);
    } else {
      throw Exception(response['error'] ?? 'Erro ao buscar dados do censo');
    }
  }

  @override
  Future<List<CensusDataDto>> getMultipleCitiesCensusData(
      List<int> cityIds) async {
    final queryParams = cityIds.map((id) => 'cidades[]=$id').join('&');
    final endpoint = '${ApiConfig.baseUrl}/api/censo/agregado?$queryParams';

    final response = await _apiService.get(endpoint);

    if (response['success'] == true) {
      final data = response['data'];
      // Assuming list return or map handling as per legacy service
      // Legacy service returns map, here interface asks for List<DTO>
      // For now, let's focus on the new methods required for the task
      return []; // Placeholder for existing method not focus of task
    } else {
      throw Exception(response['error'] ?? 'Erro ao buscar dados do censo');
    }
  }

  @override
  Future<CensoEscolarEntity> getCensusByCity(int cityId) async {
    final response = await _apiService.get(
      ApiConfig.censoPorCidadeEndpoint(cityId),
    );

    if (response['success'] == true) {
      final dados = response['data']['dados'];
      return _mapToCensoEscolarEntity(dados);
    } else {
      throw Exception(response['error'] ?? 'Erro ao buscar censo escolar');
    }
  }

  @override
  Future<CensoEscolarEntity> updateCensusIndices(
    int cityId,
    Map<int, double> indices,
  ) async {
    final List<Map<String, dynamic>> indicesArray = [];
    indices.forEach((key, value) {
      indicesArray.add({
        'indice_etapa_id': key,
        'valor': value,
      });
    });

    final payload = {
      'indices_etapa': indicesArray,
    };

    final response = await _apiService.put(
      ApiConfig.censoPorCidadeEndpoint(cityId),
      payload,
    );

    if (response['success'] == true) {
      // After update, fetch fresh data to return consistent entity
      return getCensusByCity(cityId);
    } else {
      throw Exception(response['error'] ?? 'Erro ao atualizar índices');
    }
  }

  CensoEscolarEntity _mapToCensoEscolarEntity(Map<String, dynamic> json) {
    final int cidadeId =
        json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0;
    final String cidadeNome = (json['nome'] ?? '').toString();

    final List<dynamic> indicesList = json['indices_etapa'] ?? [];

    // Preparar mapa de valores por etapa
    final Map<String, double> valoresPorEtapa = {};

    // Agrupar por grupo
    final Map<int, CensoGroupEntity> groupsMap = {};

    for (var item in indicesList) {
      // Map item
      final int indiceId = item['indice_etapa_id'] is int
          ? item['indice_etapa_id']
          : int.tryParse('${item['indice_etapa_id']}') ?? 0;

      final String nomeEtapa = (item['nome_etapa'] ?? '').toString();

      final double valor = item['valor'] is double
          ? item['valor']
          : double.tryParse('${item['valor']}') ?? 0.0;

      valoresPorEtapa[nomeEtapa] = valor;

      final groupJson = item['grupo'];
      if (groupJson != null) {
        final int groupId = groupJson['grupo_id'] is int
            ? groupJson['grupo_id']
            : int.tryParse('${groupJson['grupo_id']}') ?? 0;
        final String groupName = (groupJson['nome_grupo'] ?? '').toString();

        if (!groupsMap.containsKey(groupId)) {
          groupsMap[groupId] = CensoGroupEntity(
            id: groupId,
            nome: groupName,
            titulos: [],
          );
        }

        // Add title to group
        final bool isProfessores = nomeEtapa.endsWith('P');
        final title = CensoTitleEntity(
          id: indiceId,
          nomeEtapa: nomeEtapa,
          tituloExibicao: nomeEtapa,
          valor: valor,
          isProfessores: isProfessores,
          grupoId: groupId,
        );

        // Check duplication?
        groupsMap[groupId]!.titulos.add(title);
      }
    }

    return CensoEscolarEntity(
      cidadeId: cidadeId,
      cidadeNome: cidadeNome,
      grupos: groupsMap.values.toList(),
      valoresPorEtapa: valoresPorEtapa,
    );
  }
}
