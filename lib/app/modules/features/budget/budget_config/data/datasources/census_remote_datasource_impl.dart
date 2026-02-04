import 'dart:typed_data';

import 'package:multimidiaapp/app/shared/core/http/app_http_client.dart';
import 'package:multimidiaapp/app/shared/core/http/http_request_config.dart';
import 'package:multimidiaapp/app/shared/core/utils/token_cache.dart';
import 'package:multimidiaapp/config/api_config.dart';

import '../../domain/entities/censo_escolar_entity.dart';
import '../../domain/entities/censo_group_entity.dart';
import '../../domain/entities/censo_title_entity.dart';
import '../models/budget_census_dto.dart';
import '../models/census_data_dto.dart';
import 'census_remote_datasource.dart';

/// Implementação do datasource de censo usando AppHttpClient
class CensusRemoteDataSourceImpl implements CensusRemoteDataSource {
  final AppHttpClient _client;

  CensusRemoteDataSourceImpl(this._client);

  HttpRequestConfig get _config => HttpRequestConfig(
        token: TokenCache.instance.getTokenOrEmpty(),
      );

  @override
  Future<CensusDataDto> getCensusData(int cityId) async {
    final response = await _client.get(
      ApiConfig.censoPorCidadeEndpoint(cityId),
      config: _config,
    );

    if (response.isSuccess) {
      final data = response.body['dados'];
      return CensusDataDto.fromJson(data);
    } else {
      throw Exception(
          response.body['error'] ?? 'Erro ao buscar dados do censo');
    }
  }

  @override
  Future<List<CensusDataDto>> getMultipleCitiesCensusData(
      List<int> cityIds) async {
    final queryParams = cityIds.map((id) => 'cidades[]=$id').join('&');
    final endpoint = '${ApiConfig.baseUrl}/api/censo/agregado?$queryParams';

    final response = await _client.get(endpoint, config: _config);

    if (response.isSuccess) {
      return [];
    } else {
      throw Exception(
          response.body['error'] ?? 'Erro ao buscar dados do censo');
    }
  }

  @override
  Future<CensoEscolarEntity> getCensusByCity(int cityId) async {
    final response = await _client.get(
      ApiConfig.censoPorCidadeEndpoint(cityId),
      config: _config,
    );

    if (response.isSuccess) {
      final dados = response.body['dados'];
      return _mapToCensoEscolarEntity(dados);
    } else {
      throw Exception(response.body['error'] ?? 'Erro ao buscar censo escolar');
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

    final response = await _client.put(
      ApiConfig.censoPorCidadeEndpoint(cityId),
      data: payload,
      config: _config,
    );

    if (response.isSuccess) {
      return getCensusByCity(cityId);
    } else {
      throw Exception(response.body['error'] ?? 'Erro ao atualizar índices');
    }
  }

  CensoEscolarEntity _mapToCensoEscolarEntity(Map<String, dynamic> json) {
    final int cidadeId =
        json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0;
    final String cidadeNome = (json['nome'] ?? '').toString();

    final List<dynamic> indicesList = json['indices_etapa'] ?? [];

    final Map<String, double> valoresPorEtapa = {};
    final Map<int, CensoGroupEntity> groupsMap = {};

    for (var item in indicesList) {
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

        final bool isProfessores = nomeEtapa.endsWith('P');
        final title = CensoTitleEntity(
          id: indiceId,
          nomeEtapa: nomeEtapa,
          tituloExibicao: tituloEtapa,
          valor: valor,
          isProfessores: isProfessores,
          grupoId: groupId,
        );

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
  Future<BudgetCensusDto> updateBudgetCensusIndices({
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

    final response = await _client.patch(
      '${ApiConfig.baseUrl}/api/orcamentos/$budgetId/censo',
      data: payload,
      config: _config,
    );

    if (response.isSuccess) {
      final data = response.body as Map<String, dynamic>? ?? {};
      return BudgetCensusDto.fromJson(data);
    } else {
      throw Exception(
          response.body['error'] ?? 'Erro ao atualizar censo do orçamento');
    }
  }

  @override
  Future<BudgetCensusDto> getBudgetCensus(int budgetId) async {
    final response = await _client.get(
      '${ApiConfig.baseUrl}/api/orcamentos/$budgetId/censo',
      config: _config,
    );

    if (response.isSuccess) {
      final data = response.body as Map<String, dynamic>? ?? {};
      return BudgetCensusDto.fromJson(data);
    } else {
      throw Exception(
          response.body['error'] ?? 'Erro ao buscar censo do orçamento');
    }
  }

  @override
  Future<Uint8List> exportCensusCsv(int budgetId) async {
    try {
      final bytes = await _client.getBytes(
        '${ApiConfig.baseUrl}/api/orcamentos/$budgetId/censo/exportar',
        config: _config,
      );

      return Uint8List.fromList(bytes);
    } catch (e) {
      rethrow;
    }
  }
}
