import 'dart:typed_data';

import 'package:multimidiaapp/app/shared/core/http/app_http_client.dart';
import 'package:multimidiaapp/app/shared/core/http/http_request_config.dart';
import 'package:multimidiaapp/app/shared/core/utils/token_cache.dart';
import 'package:multimidiaapp/app/shared/domain/value_objects/fractional_order.dart';
import 'package:multimidiaapp/app/shared/utils/api_number_parser.dart';
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

  int _toInt(dynamic value) => ApiNumberParser.toInt(value);

  int? _toNullableInt(dynamic value) {
    final parsed = _toInt(value);
    return parsed == 0 ? null : parsed;
  }

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
    final response = await _client.post(
      '${ApiConfig.baseUrl}/api/censo/agregado',
      data: {'cidades': cityIds},
      config: _config,
    );

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
    final int cidadeId = _toInt(json['id']);
    final String cidadeNome = (json['nome'] ?? '').toString();

    final List<dynamic> indicesList = json['indices_etapa'] ?? [];

    final Map<String, double> valoresPorEtapa = {};
    final Map<int, List<CensoTitleEntity>> titlesPerGroup = {};
    final Map<int, String> groupNames = {};
    final Map<int, FractionalOrder> groupOrders = {};

    for (var item in indicesList) {
      final int indiceId = _toInt(item['indice_etapa_id']);
      final String nomeEtapa = (item['nome_etapa'] ?? '') as String;
      final String tituloEtapa = (item['titulo_etapa'] ?? '') as String;
      final double valor = ApiNumberParser.toDouble(item['valor']);

      valoresPorEtapa[nomeEtapa] = valor;

      final groupJson = item['grupo'];
      if (groupJson != null) {
        final int groupId = _toInt(groupJson['grupo_id']);
        final String groupName = (groupJson['nome_grupo'] ?? '') as String;

        groupNames[groupId] = groupName;
        groupOrders[groupId] =
            FractionalOrder.tryParse(groupJson['grupo_ordem']);
        titlesPerGroup.putIfAbsent(groupId, () => []);

        final bool isProfessores = nomeEtapa.endsWith('P');
        final title = CensoTitleEntity(
          id: indiceId,
          nomeEtapa: nomeEtapa,
          tituloExibicao: tituloEtapa,
          valor: valor,
          isProfessores: isProfessores,
          grupoId: groupId,
          percentualPopulacao:
              ApiNumberParser.toDoubleOrNull(item['percentual_populacao']),
          ordem: FractionalOrder.tryParse(item['ind_ordem']),
        );

        titlesPerGroup[groupId]!.add(title);
      }
    }

    final List<CensoGroupEntity> grupos = titlesPerGroup.entries.map((entry) {
      final titulos = entry.value..sort((a, b) => a.ordem.compareTo(b.ordem));
      return CensoGroupEntity(
        id: entry.key,
        nome: groupNames[entry.key] ?? '',
        titulos: titulos,
        ordem: groupOrders[entry.key] ?? FractionalOrder.zero,
      );
    }).toList()
      ..sort((a, b) => a.ordem.compareTo(b.ordem));

    return CensoEscolarEntity(
      cidadeId: cidadeId,
      cidadeNome: cidadeNome,
      censoAno: _toNullableInt(json['censo_ano']),
      anoPopulacao: _toNullableInt(json['ano_populacao']),
      grupos: grupos,
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
