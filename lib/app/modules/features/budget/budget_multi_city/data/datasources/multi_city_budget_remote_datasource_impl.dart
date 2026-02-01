import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_escolar_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_group_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_title_entity.dart';
import 'package:multimidiaapp/config/api_config.dart';
import 'package:multimidiaapp/services/api_service.dart';

import 'multi_city_budget_remote_datasource.dart';

/// Implementação concreta do datasource multi-cidades
class MultiCityBudgetRemoteDataSourceImpl
    implements MultiCityBudgetRemoteDataSource {
  final ApiService _apiService;

  MultiCityBudgetRemoteDataSourceImpl(this._apiService);

  /// Constrói payload de cidades com overrides para envio à API
  List<Map<String, dynamic>> _buildCidadesPayload(
    List<int> cidadeIds,
    Map<int, Map<int, double>> overridesPorCidade,
  ) {
    return cidadeIds.map((cidadeId) {
      final overrides = overridesPorCidade[cidadeId] ?? {};
      final overridesList = overrides.entries
          .map((e) => {
                'indice_etapa_id': e.key,
                'valor': e.value,
              })
          .toList();

      return {
        'cidade_id': cidadeId,
        'overrides': overridesList,
      };
    }).toList();
  }

  @override
  Future<Map<int, CensoEscolarEntity>> buscarCensosMultiCidade(
    List<int> cidadeIds,
  ) async {
    final Map<int, CensoEscolarEntity> result = {};

    // Buscar censo para cada cidade individualmente
    for (final cidadeId in cidadeIds) {
      final response = await _apiService.get(
        ApiConfig.censoPorCidadeEndpoint(cidadeId),
      );

      if (response['success'] == true) {
        final dados = response['data']['dados'];
        result[cidadeId] = _mapToCensoEscolarEntity(dados);
      } else {
        throw Exception(
          response['error'] ?? 'Erro ao buscar censo da cidade $cidadeId',
        );
      }
    }

    return result;
  }

  @override
  Future<Map<String, dynamic>> previewMultiCidade({
    required String nome,
    required List<int> cidadeIds,
    required Map<int, Map<int, double>> overridesPorCidade,
  }) async {
    final cidades = _buildCidadesPayload(cidadeIds, overridesPorCidade);
    final payload = {
      'orc_nome': nome,
      'cidades': cidades,
    };

    final response = await _apiService.post(
      '${ApiConfig.baseUrl}/api/orcamentos/multi-cidade/preview',
      payload,
    );

    if (response['success'] == true) {
      final data = response['data'];
      return data['dados'] as Map<String, dynamic>? ??
          data as Map<String, dynamic>;
    } else {
      throw Exception(response['error'] ?? 'Erro ao fazer preview');
    }
  }

  @override
  Future<Map<String, dynamic>> criarMultiCidade({
    required String nome,
    required int diasValidade,
    required int usuarioId,
    required List<int> cidadeIds,
    required Map<int, Map<int, double>> overridesPorCidade,
    int? partnerDestinoId,
  }) async {
    final cidades = _buildCidadesPayload(cidadeIds, overridesPorCidade);
    final payload = <String, dynamic>{
      'orc_nome': nome,
      'orc_dias_validade': diasValidade,
      'orc_usuario_id': usuarioId,
      'cidades': cidades,
    };

    if (partnerDestinoId != null) {
      payload['orc_partner_destino_id'] = partnerDestinoId;
    }

    final response = await _apiService.post(
      '${ApiConfig.baseUrl}/api/orcamentos/multi-cidade',
      payload,
    );

    if (response['success'] == true) {
      final data = response['data'];
      final dados = data['dados'] as Map<String, dynamic>? ?? data;

      // Validar que temos o ID
      final id = dados['id'] ?? dados['orc_orcamentoId'];
      if (id == null) {
        throw Exception('ID do orçamento não retornado');
      }

      // Retornar dados completos (categorias, cidades, censo_agregado)
      return dados;
    } else {
      throw Exception(
          response['error'] ?? 'Erro ao criar orçamento multi-cidade');
    }
  }

  @override
  Future<void> atualizarCidades({
    required int budgetId,
    required List<int> cidadeIds,
    required Map<int, Map<int, double>> overridesPorCidade,
  }) async {
    final cidades = _buildCidadesPayload(cidadeIds, overridesPorCidade);
    final payload = {
      'cidades': cidades,
    };

    final response = await _apiService.put(
      '${ApiConfig.baseUrl}/api/orcamentos/$budgetId',
      payload,
    );

    if (response['success'] != true) {
      throw Exception(response['error'] ?? 'Erro ao atualizar cidades');
    }
  }

  /// Mapeia resposta JSON para CensoEscolarEntity
  CensoEscolarEntity _mapToCensoEscolarEntity(Map<String, dynamic> json) {
    final int cidadeId =
        json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0;
    final String cidadeNome = (json['nome'] ?? '').toString();

    final List<dynamic> indicesList = json['indices_etapa'] ?? [];

    // Preparar mapa de valores por etapa
    final Map<String, double> valoresPorEtapa = {};

    // Agrupar títulos por grupo
    final Map<int, List<CensoTitleEntity>> titlesPerGroup = {};
    final Map<int, String> groupNames = {};

    for (var item in indicesList) {
      final int indiceId = item['indice_etapa_id'] is int
          ? item['indice_etapa_id']
          : int.tryParse('${item['indice_etapa_id']}') ?? 0;

      final String nomeEtapa = (item['nome_etapa'] ?? '').toString();
      // Fallback: usar nome_etapa se titulo_etapa estiver vazio
      String tituloEtapa = (item['titulo_etapa'] ?? '').toString();
      if (tituloEtapa.isEmpty) {
        tituloEtapa = nomeEtapa;
      }

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

        groupNames[groupId] = groupName;
        titlesPerGroup.putIfAbsent(groupId, () => []);

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

    // Criar entidades de grupo
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
