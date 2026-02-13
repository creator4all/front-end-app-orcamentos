import '../../domain/entities/censo_escolar_entity.dart';
import '../../domain/entities/censo_group_entity.dart';
import '../../domain/entities/censo_title_entity.dart';

class CensoEscolarDto {
  static CensoEscolarEntity fromApi(Map<String, dynamic> cidadeData) {
    final cidade = cidadeData;
    final cidadesHasIndiceEtapa = cidade['cidades_has_indice_etapa'] as List;

    final valoresPorEtapa = <String, double>{};

    final gruposMap = <int, List<Map<String, dynamic>>>{};

    for (final item in cidadesHasIndiceEtapa) {
      final etapa = item['nome_etapa'] as String;
      final tituloEtapa = item['titulo_etapa'] as String;
      final valor = double.parse(item['pivot']['etapa_valor'].toString());
      final grupo = item['grupo'];
      final grupoId = grupo['grupo_id'] as int;
      final grupoNome = grupo['nome_grupo'] as String;

      valoresPorEtapa[etapa] = valor;

      if (!gruposMap.containsKey(grupoId)) {
        gruposMap[grupoId] = [];
      }
      gruposMap[grupoId]!.add({
        'id': item['idindice_etapa'],
        'nomeEtapa': etapa,
        'tituloEtapa': tituloEtapa,
        'grupoId': grupoId,
        'grupoNome': grupoNome,
        'valor': valor,
      });
    }

    final grupos = gruposMap.entries.map((entry) {
      final grupoId = entry.key;
      final itens = entry.value;
      final grupoNome = itens.first['grupoNome'];

      final titulos = itens.map((item) {
        final nomeEtapa = item['nomeEtapa'] as String;
        final tituloEtapa = item['tituloEtapa'] as String;
        final isProfessores = nomeEtapa.endsWith('P');

        return CensoTitleEntity(
          id: item['id'],
          nomeEtapa: nomeEtapa,
          tituloExibicao: tituloEtapa,
          valor: item['valor'],
          isProfessores: isProfessores,
          grupoId: grupoId,
        );
      }).toList();

      return CensoGroupEntity(
        id: grupoId,
        nome: grupoNome,
        titulos: titulos,
      );
    }).toList();

    return CensoEscolarEntity(
      cidadeId: cidade['idCidades'],
      cidadeNome: cidade['nome_cidade'],
      censoAno: cidade['censo_ano'] as int?,
      grupos: grupos,
      valoresPorEtapa: valoresPorEtapa,
    );
  }
}
