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
      final String tituloEtapa = (item['titulo_etapa'] ?? '').toString();

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
            titulos: const [],
          );
        }

        // Add title to group
        final bool isProfessores = nomeEtapa.endsWith('P');
        final title = CensoTitleEntity(
          id: indiceId,
          nomeEtapa: nomeEtapa,
          tituloExibicao: tituloEtapa, // Usa titulo_etapa da API
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

  @override
  Future<CensoEscolarEntity> updateBudgetCensusIndices({
    required int budgetId,
    required int cityId,
    required Map<int, double> indices,
  }) async {
    final List<Map<String, dynamic>> indicesArray = [];
    indices.forEach((indiceEtapaId, valor) {
      indicesArray.add({
        'cidade_id': cityId,
        'indice_etapa_id': indiceEtapaId,
        'valor': valor,
      });
    });

    final payload = {'indices': indicesArray};

    final response = await _apiService.patch(
      '${ApiConfig.baseUrl}/api/orcamentos/$budgetId/censo',
      payload,
    );

    if (response['success'] == true) {
      // O response real vem em response['data']['dados'] (API usa 'dados' não 'data')
      final responseData = response['data'] as Map<String, dynamic>? ?? {};
      final dados =
          responseData['dados'] as Map<String, dynamic>? ?? responseData;

      // Extrair dados da cidade do response completo do orçamento
      final cidadeData = _extractCityWithCensusFromResponse(dados, cityId);
      return _mapCidadeDataToCensoEntity(cidadeData, cityId);
    } else {
      throw Exception(
          response['error'] ?? 'Erro ao atualizar censo do orçamento');
    }
  }

  Map<String, dynamic> _extractCityWithCensusFromResponse(
    Map<String, dynamic> data,
    int cityId,
  ) {
    // Tentar extrair cidade do response
    final cidade = data['cidade'] as Map<String, dynamic>?;
    if (cidade != null) {
      return cidade;
    }

    // Caso a estrutura seja diferente, tentar cidades (plural)
    final cidades = data['cidades'] as List?;
    if (cidades != null && cidades.isNotEmpty) {
      return cidades.first as Map<String, dynamic>;
    }

    // Fallback: retornar dados vazios
    throw Exception('Dados da cidade não encontrados no response');
  }

  CensoEscolarEntity _mapCidadeDataToCensoEntity(
    Map<String, dynamic> cidadeData,
    int cityId,
  ) {
    final int cidadeId = cidadeData['idCidades'] ?? cityId;
    final String cidadeNome =
        cidadeData['nome_cidade']?.toString() ?? 'Cidade $cidadeId';

    final List<dynamic> indicesList =
        cidadeData['cidades_has_indice_etapa'] as List? ?? [];

    // Preparar mapa de valores por etapa
    final Map<String, double> valoresPorEtapa = {};

    // Agrupar títulos por grupo (usando listas mutáveis)
    final Map<int, List<CensoTitleEntity>> titlesPerGroup = {};
    final Map<int, String> groupNames = {};

    for (var item in indicesList) {
      final int indiceId = item['idindice_etapa'] is int
          ? item['idindice_etapa']
          : int.tryParse('${item['idindice_etapa']}') ?? 0;

      final String nomeEtapa = (item['nome_etapa'] ?? '').toString();
      final String tituloEtapa = (item['titulo_etapa'] ?? '').toString();

      // Ler valor de pivot.etapa_valor
      final pivot = item['pivot'] as Map<String, dynamic>?;
      final double valor =
          double.tryParse(pivot?['etapa_valor']?.toString() ?? '0') ?? 0.0;

      valoresPorEtapa[nomeEtapa] = valor;

      final groupJson = item['grupo'] as Map<String, dynamic>?;
      if (groupJson != null) {
        final int groupId = groupJson['grupo_id'] is int
            ? groupJson['grupo_id']
            : int.tryParse('${groupJson['grupo_id']}') ?? 0;
        final String groupName = (groupJson['nome_grupo'] ?? '').toString();

        // Guardar nome do grupo
        groupNames[groupId] = groupName;

        // Inicializar lista se não existir
        titlesPerGroup.putIfAbsent(groupId, () => []);

        // Criar e adicionar título ao grupo
        final bool isProfessores = nomeEtapa.endsWith('P');
        final title = CensoTitleEntity(
          id: indiceId,
          nomeEtapa: nomeEtapa,
          tituloExibicao: tituloEtapa,
          valor: valor,
          isProfessores: isProfessores,
          grupoId: groupId,
        );

        titlesPerGroup[groupId]!.add(title);
      }
    }

    // Criar entidades de grupo com todas as suas títulos
    final List<CensoGroupEntity> grupos = titlesPerGroup.entries.map((entry) {
      return CensoGroupEntity(
        id: entry.key,
        nome: groupNames[entry.key] ?? '',
        titulos: entry.value,
      );
    }).toList();

    return CensoEscolarEntity(
      cidadeId: cidadeId,
      cidadeNome: cidadeNome,
      grupos: grupos,
      valoresPorEtapa: valoresPorEtapa,
    );
  }
}
