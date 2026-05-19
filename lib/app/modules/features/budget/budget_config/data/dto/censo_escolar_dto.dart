import '../../domain/entities/censo_escolar_entity.dart';
import '../../domain/entities/censo_group_entity.dart';
import '../../domain/entities/censo_title_entity.dart';

class CensoEscolarDto {
  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static CensoEscolarEntity fromApi(Map<String, dynamic> cidadeData) {
    final cidade = cidadeData;
    final rawIndices = cidade['indices'] as List? ??
        cidade['indicadores'] as List? ??
        cidade['cidades_has_indice_etapa'] as List? ??
        const [];

    final valoresPorEtapa = <String, double>{};

    final gruposMap = <int, List<Map<String, dynamic>>>{};

    for (final raw in rawIndices.whereType<Map>()) {
      final item = Map<String, dynamic>.from(raw);
      final grupo = item['grupo'] as Map<String, dynamic>?;
      final pivot = item['pivot'] as Map<String, dynamic>?;

      final etapa = (item['nome_etapa'] ?? item['nome'] ?? '').toString();
      final tituloEtapa = (item['titulo'] ??
              item['titulo_etapa'] ??
              item['nome'] ??
              item['nome_etapa'] ??
              '')
          .toString();
      final valor = _toDouble(
        item['valor'] ?? item['etapa_valor'] ?? pivot?['etapa_valor'],
      );
      final grupoId = _toInt(
        item['grupo_id'] ??
            item['grupos_grupo_id'] ??
            grupo?['id'] ??
            grupo?['grupo_id'],
      );
      final grupoNome =
          (item['grupo_nome'] ?? grupo?['nome'] ?? grupo?['nome_grupo'] ?? '')
              .toString();

      valoresPorEtapa[etapa] = valor;

      if (!gruposMap.containsKey(grupoId)) {
        gruposMap[grupoId] = [];
      }
      gruposMap[grupoId]!.add({
        'id': _toInt(
          item['id'] ??
              item['idindice_etapa'] ??
              item['indice_etapa_id'] ??
              item['indice_etapa_idindice_etapa'],
        ),
        'nomeEtapa': etapa,
        'tituloEtapa': tituloEtapa,
        'grupoId': grupoId,
        'grupoNome': grupoNome,
        'valor': valor,
        'percentualPopulacao': item['percentual_populacao'] != null
            ? _toDouble(item['percentual_populacao'])
            : null,
      });
    }

    final grupos = gruposMap.entries.map((entry) {
      final grupoId = entry.key;
      final itens = entry.value;
      final grupoNome = itens.first['grupoNome'].toString();

      final titulos = itens.map((item) {
        final nomeEtapa = item['nomeEtapa'] as String;
        final tituloEtapa = item['tituloEtapa'] as String;
        final isProfessores = nomeEtapa.endsWith('P');

        return CensoTitleEntity(
          id: _toInt(item['id']),
          nomeEtapa: nomeEtapa,
          tituloExibicao: tituloEtapa,
          valor: _toDouble(item['valor']),
          isProfessores: isProfessores,
          grupoId: grupoId,
          percentualPopulacao: item['percentualPopulacao'] != null
              ? _toDouble(item['percentualPopulacao'])
              : null,
        );
      }).toList();

      return CensoGroupEntity(
        id: grupoId,
        nome: grupoNome,
        titulos: titulos,
      );
    }).toList();

    return CensoEscolarEntity(
      cidadeId: _toInt(cidade['id'] ?? cidade['idCidades']),
      cidadeNome: (cidade['nome'] ?? cidade['nome_cidade'] ?? '').toString(),
      censoAno:
          _toInt(cidade['censo_ano']) == 0 ? null : _toInt(cidade['censo_ano']),
      anoPopulacao: _toInt(cidade['ano_populacao']) == 0
          ? null
          : _toInt(cidade['ano_populacao']),
      grupos: grupos,
      valoresPorEtapa: valoresPorEtapa,
    );
  }
}
