import '../../../../../../shared/domain/value_objects/fractional_order.dart';
import '../../../../../../shared/utils/api_number_parser.dart';
import '../entities/censo_escolar_entity.dart';
import '../entities/censo_group_entity.dart';
import '../entities/censo_title_entity.dart';

/// Mapper de domínio que centraliza a conversão entre os contratos brutos
/// (`Map<String, dynamic>` vindos da API ou de `citiesData`) e a entidade
/// [CensoEscolarEntity].
///
/// Pontos-chave:
/// - Extrai `ind_ordem` (ordem do índice) e `grupo.ordem` (ordem do grupo) em
///   todos os caminhos, preservando a precisão decimal via [FractionalOrder].
/// - Ordena grupos por `grupo.ordem` e títulos por `ind_ordem` em toda
///   construção de entidade.
/// - O censo agregado é montado por **união** dos índices de todas as cidades,
///   de forma que etapas exclusivas de cidades secundárias também apareçam.
class CensoEscolarMapper {
  const CensoEscolarMapper();

  // ── Extração / normalização ──────────────────────────────────────────────

  /// Extrai a lista de índices normalizados de uma cidade, aceitando as
  /// chaves `indices`, `indicadores` e `cidades_has_indice_etapa`.
  List<Map<String, dynamic>> extractIndicesFromCityData(
    Map<String, dynamic> cityData,
  ) {
    final rawIndices = cityData['indices'] as List? ??
        cityData['indicadores'] as List? ??
        cityData['cidades_has_indice_etapa'] as List? ??
        const [];

    return rawIndices
        .whereType<Map>()
        .map((item) => _normalizeCityIndice(Map<String, dynamic>.from(item)))
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  /// Normaliza um índice bruto para o formato canônico consumido pela
  /// construção de entidades, incluindo os campos de ordem.
  Map<String, dynamic>? _normalizeCityIndice(Map<String, dynamic> item) {
    final group = item['grupo'] as Map<String, dynamic>?;
    final pivot = item['pivot'] as Map<String, dynamic>?;

    final groupId = ApiNumberParser.toInt(
      item['grupo_id'] ??
          item['grupos_grupo_id'] ??
          group?['id'] ??
          group?['grupo_id'],
    );
    final groupName =
        (item['grupo_nome'] ?? group?['nome'] ?? group?['nome_grupo'] ?? '')
            .toString();
    final nomeEtapa = (item['nome_etapa'] ?? item['nome'] ?? '').toString();
    if (nomeEtapa.isEmpty) return null;

    final titulo = (item['titulo'] ??
            item['titulo_etapa'] ??
            item['nome'] ??
            item['nome_etapa'] ??
            '')
        .toString();
    final valor = ApiNumberParser.toDouble(
      item['valor'] ?? item['etapa_valor'] ?? pivot?['etapa_valor'],
    );

    final indOrdem = item['ind_ordem'] ?? item['ordem'];
    final grupoOrdem =
        item['grupo_ordem'] ?? group?['ordem'] ?? group?['grupo_ordem'];

    return <String, dynamic>{
      'id': ApiNumberParser.toInt(
        item['id'] ??
            item['idindice_etapa'] ??
            item['indice_etapa_id'] ??
            item['indice_etapa_idindice_etapa'],
      ),
      'nome_etapa': nomeEtapa,
      'titulo': titulo,
      'valor': valor,
      'percentual_populacao': item['percentual_populacao'],
      'ind_ordem': indOrdem,
      'grupo': {
        'id': groupId,
        'nome': groupName,
        'ordem': grupoOrdem,
      },
    };
  }

  // ── Construção de entidades ──────────────────────────────────────────────

  /// Constrói [CensoEscolarEntity] a partir dos dados brutos de uma única
  /// cidade, ordenando grupos por `grupo.ordem` e títulos por `ind_ordem`.
  CensoEscolarEntity? buildCensoFromCityData(Map<String, dynamic> cityData) {
    final normalizedIndices = extractIndicesFromCityData(cityData);
    if (normalizedIndices.isEmpty) return null;

    final valoresPorEtapa = <String, double>{};
    final gruposMap = <int, List<CensoTitleEntity>>{};
    final grupoNomes = <int, String>{};
    final grupoOrdens = <int, FractionalOrder>{};

    for (final indice in normalizedIndices) {
      final nomeEtapa = indice['nome_etapa'].toString();
      final titulo = indice['titulo'].toString();
      final valor = ApiNumberParser.toDouble(indice['valor']);
      final group = indice['grupo'] as Map<String, dynamic>? ?? const {};
      final grupoId = ApiNumberParser.toInt(group['id']);
      final grupoNome = (group['nome'] ?? '').toString();
      final id = ApiNumberParser.toInt(indice['id']);
      final ordem = FractionalOrder.tryParse(indice['ind_ordem']);
      final grupoOrdem = FractionalOrder.tryParse(group['ordem']);

      valoresPorEtapa[nomeEtapa] = valor;
      // Primeiro valor não-zero vence — índice sem ordem não sobrescreve.
      final ordemAtual = grupoOrdens[grupoId];
      if (ordemAtual == null || ordemAtual == FractionalOrder.zero) {
        grupoOrdens[grupoId] = grupoOrdem;
      }
      if (grupoNome.isNotEmpty) grupoNomes[grupoId] = grupoNome;

      gruposMap.putIfAbsent(grupoId, () => []);
      gruposMap[grupoId]!.add(
        CensoTitleEntity(
          id: id,
          nomeEtapa: nomeEtapa,
          tituloExibicao: titulo,
          valor: valor,
          isProfessores: nomeEtapa.endsWith('P'),
          grupoId: grupoId,
          percentualPopulacao: indice['percentual_populacao'] != null
              ? ApiNumberParser.toDouble(indice['percentual_populacao'])
              : null,
          ordem: ordem,
        ),
      );
    }

    final grupos = _buildSortedGroups(gruposMap, grupoNomes, grupoOrdens);

    return CensoEscolarEntity(
      cidadeId: ApiNumberParser.toInt(cityData['id'] ?? cityData['idCidades']),
      cidadeNome:
          (cityData['nome'] ?? cityData['nome_cidade'] ?? '').toString(),
      censoAno: ApiNumberParser.toInt(cityData['censo_ano']) == 0
          ? null
          : ApiNumberParser.toInt(cityData['censo_ano']),
      anoPopulacao: ApiNumberParser.toInt(cityData['ano_populacao']) == 0
          ? null
          : ApiNumberParser.toInt(cityData['ano_populacao']),
      grupos: grupos,
      valoresPorEtapa: valoresPorEtapa,
    );
  }

  /// Constrói o [CensoEscolarEntity] agregado por **união** dos índices de
  /// todas as cidades, usando os valores somados de [censoAgregado].
  ///
  /// A estrutura (grupos e títulos) é montada percorrendo todas as cidades,
  /// de forma que etapas exclusivas de cidades secundárias também apareçam.
  /// Grupos e títulos são ordenados por `ordem`.
  CensoEscolarEntity buildAggregatedCenso({
    required Map<String, double> censoAgregado,
    required List<Map<String, dynamic>> citiesData,
  }) {
    if (citiesData.isEmpty) {
      final grupos = <CensoGroupEntity>[
        CensoGroupEntity(
          id: 0,
          nome: 'Agregado',
          titulos: censoAgregado.entries
              .map(
                (e) => CensoTitleEntity(
                  id: 0,
                  nomeEtapa: e.key,
                  tituloExibicao: e.key,
                  valor: e.value,
                  isProfessores: e.key.endsWith('P'),
                  grupoId: 0,
                ),
              )
              .toList(),
        ),
      ];

      return CensoEscolarEntity(
        cidadeId: 0,
        cidadeNome: 'Agregado',
        anoPopulacao: null,
        grupos: grupos,
        valoresPorEtapa: censoAgregado,
      );
    }

    final gruposMap = <int, List<CensoTitleEntity>>{};
    final grupoNomes = <int, String>{};
    final grupoOrdens = <int, FractionalOrder>{};
    final vistos = <String>{};

    for (final cityData in citiesData) {
      final indices = extractIndicesFromCityData(cityData);
      for (final indice in indices) {
        final nomeEtapa = indice['nome_etapa'].toString();
        final group = indice['grupo'] as Map<String, dynamic>? ?? const {};
        final grupoId = ApiNumberParser.toInt(group['id']);
        final grupoNome = (group['nome'] ?? '').toString();
        final grupoOrdem = FractionalOrder.tryParse(group['ordem']);

        // Registrar metadados do grupo antes da dedup: uma etapa deduplicada
        // ainda pode contribuir com a ordem do grupo. Como `_buildSortedGroups`
        // itera gruposMap.entries, entradas órfãs em grupoNomes/grupoOrdens
        // são ignoradas — sem risco de criar grupo vazio.
        final ordemAtual = grupoOrdens[grupoId];
        if (ordemAtual == null || ordemAtual == FractionalOrder.zero) {
          grupoOrdens[grupoId] = grupoOrdem;
        }
        if (grupoNome.isNotEmpty) grupoNomes[grupoId] = grupoNome;

        // Dedup global por nomeEtapa: a primeira ocorrência define o grupo.
        // Registrar o grupo só quando vamos efetivamente adicionar um título
        // evita criar grupos vazios quando a mesma etapa aparece em grupos
        // diferentes entre cidades.
        if (vistos.contains(nomeEtapa)) continue;
        vistos.add(nomeEtapa);

        final titulo = indice['titulo'].toString();
        final id = ApiNumberParser.toInt(indice['id']);
        final ordem = FractionalOrder.tryParse(indice['ind_ordem']);
        final valorAgregado = censoAgregado[nomeEtapa] ?? 0.0;

        gruposMap.putIfAbsent(grupoId, () => []);

        gruposMap[grupoId]!.add(
          CensoTitleEntity(
            id: id,
            nomeEtapa: nomeEtapa,
            tituloExibicao: titulo,
            valor: valorAgregado,
            isProfessores: nomeEtapa.endsWith('P'),
            grupoId: grupoId,
            percentualPopulacao: indice['percentual_populacao'] != null
                ? ApiNumberParser.toDouble(indice['percentual_populacao'])
                : null,
            ordem: ordem,
          ),
        );
      }
    }

    final grupos = _buildSortedGroups(gruposMap, grupoNomes, grupoOrdens);

    return CensoEscolarEntity(
      cidadeId: 0,
      cidadeNome: 'Agregado',
      anoPopulacao: null,
      grupos: grupos,
      valoresPorEtapa: censoAgregado,
    );
  }

  /// Soma os valores de cada etapa a partir das cidades brutas, retornando
  /// o mapa agregado. Usa [fallback] quando não há dados.
  Map<String, double> calculateAggregatedCensoFromCities(
    List<Map<String, dynamic>> citiesData,
    Map<String, double> fallback,
  ) {
    final aggregated = <String, double>{};

    for (final city in citiesData) {
      final indices = extractIndicesFromCityData(city);
      for (final indice in indices) {
        final nomeEtapa = indice['nome_etapa'].toString();
        if (nomeEtapa.isEmpty) continue;
        aggregated[nomeEtapa] = (aggregated[nomeEtapa] ?? 0) +
            ApiNumberParser.toDouble(indice['valor']);
      }
    }

    if (aggregated.isNotEmpty) return aggregated;
    return Map<String, double>.from(fallback);
  }

  // ── Serialização reversa (entidade → Map) ────────────────────────────────

  /// Reconstrói a lista de índices a partir de uma [CensoEscolarEntity],
  /// preservando grupo e ordem.
  List<Map<String, dynamic>> buildIndicesFromCenso(CensoEscolarEntity censo) {
    final indices = <Map<String, dynamic>>[];

    for (final grupo in censo.grupos) {
      for (final titulo in grupo.titulos) {
        indices.add({
          'id': titulo.id,
          'nome_etapa': titulo.nomeEtapa,
          'titulo': titulo.tituloExibicao,
          'valor': titulo.valor,
          'ind_ordem': titulo.ordem,
          'grupo': {
            'id': grupo.id,
            'nome': grupo.nome,
            'ordem': grupo.ordem,
          },
        });
      }
    }

    return indices;
  }

  /// Constrói a lista de indicadores a partir de índices normalizados.
  List<Map<String, dynamic>> buildIndicadoresFromIndices(
    List<Map<String, dynamic>> indices,
  ) {
    return indices.map((item) {
      final grupo = item['grupo'] as Map<String, dynamic>? ?? const {};
      return <String, dynamic>{
        'id': item['id'],
        'nome': item['nome_etapa'],
        'titulo': item['titulo'],
        'valor': item['valor'],
        'ind_ordem': item['ind_ordem'],
        'grupo_id': ApiNumberParser.toInt(grupo['id']),
        'grupo_nome': (grupo['nome'] ?? '').toString(),
        'grupo_ordem': grupo['ordem'],
      };
    }).toList();
  }

  /// Constrói a lista de índices no formato legado (`cidades_has_indice_etapa`)
  /// a partir de índices normalizados.
  List<Map<String, dynamic>> buildLegacyIndicesFromIndices(
    List<Map<String, dynamic>> indices,
    int cidadeId,
  ) {
    return indices.map((item) {
      final grupo = item['grupo'] as Map<String, dynamic>? ?? const {};
      final grupoId = ApiNumberParser.toInt(grupo['id']);
      final grupoNome = (grupo['nome'] ?? '').toString();

      return <String, dynamic>{
        'idindice_etapa': ApiNumberParser.toInt(item['id']),
        'nome_etapa': item['nome_etapa'],
        'titulo_etapa': item['titulo'],
        'ind_ordem': item['ind_ordem'],
        'grupos_grupo_id': grupoId,
        'grupo': {
          'grupo_id': grupoId,
          'nome_grupo': grupoNome,
          'grupo_ordem': grupo['ordem'],
        },
        'pivot': {
          'cidades_idCidades': cidadeId,
          'indice_etapa_idindice_etapa': ApiNumberParser.toInt(item['id']),
          'etapa_valor': ApiNumberParser.toDouble(item['valor']),
        },
      };
    }).toList();
  }

  /// Atualiza os dados brutos de uma cidade com um [CensoEscolarEntity]
  /// editado, preservando nome e ID existentes quando presentes.
  Map<String, dynamic> updateCityDataWithCenso(
    Map<String, dynamic> cityData,
    CensoEscolarEntity updatedCenso,
  ) {
    final indices = buildIndicesFromCenso(updatedCenso);
    final existingName = cityData['nome'] ?? cityData['nome_cidade'];
    final cityName = existingName == null || existingName.toString().isEmpty
        ? updatedCenso.cidadeNome
        : existingName.toString();
    final existingId = ApiNumberParser.toInt(
      cityData['id'] ?? cityData['idCidades'],
    );

    return {
      ...cityData,
      'id': existingId > 0 ? existingId : updatedCenso.cidadeId,
      'nome': cityName,
      'indices': indices,
      'indicadores': buildIndicadoresFromIndices(indices),
      'cidades_has_indice_etapa':
          buildLegacyIndicesFromIndices(indices, updatedCenso.cidadeId),
    };
  }

  // ── Helpers internos ─────────────────────────────────────────────────────

  /// Constrói a lista de grupos ordenada por `grupo.ordem`, com títulos
  /// ordenados por `ind_ordem` dentro de cada grupo.
  List<CensoGroupEntity> _buildSortedGroups(
    Map<int, List<CensoTitleEntity>> gruposMap,
    Map<int, String> grupoNomes,
    Map<int, FractionalOrder> grupoOrdens,
  ) {
    final grupos = gruposMap.entries.map((entry) {
      final titulos = entry.value..sort((a, b) => a.ordem.compareTo(b.ordem));
      return CensoGroupEntity(
        id: entry.key,
        nome: grupoNomes[entry.key] ?? '',
        titulos: titulos,
        ordem: grupoOrdens[entry.key] ?? FractionalOrder.zero,
      );
    }).toList()
      ..sort((a, b) => a.ordem.compareTo(b.ordem));

    return grupos;
  }
}
