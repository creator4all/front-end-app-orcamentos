import '../../domain/entities/censo_escolar_entity.dart';
import '../../domain/entities/censo_group_entity.dart';
import '../../domain/entities/censo_title_entity.dart';

/// DTO para converter dados do censo da API para entidades
class CensoEscolarDto {
  /// Converte os dados da API para uma entidade CensoEscolarEntity
  static CensoEscolarEntity fromApi(Map<String, dynamic> cidadeData) {
    // A API retorna os dados diretamente no objeto cidade
    // Ex: { "idCidades": 25, "nome_cidade": "Junqueiro", "cidades_has_indice_etapa": [...] }
    final cidade = cidadeData;
    final cidadesHasIndiceEtapa = cidade['cidades_has_indice_etapa'] as List;

    // Criar mapa de valores por etapa para lookup rápido
    final valoresPorEtapa = <String, double>{};

    // Agrupar por grupos
    final gruposMap = <int, List<Map<String, dynamic>>>{};

    for (final item in cidadesHasIndiceEtapa) {
      final etapa = item['nome_etapa'] as String;
      final tituloEtapa = item['titulo_etapa'] as String;
      final valor = double.parse(item['pivot']['etapa_valor'].toString());
      final grupo = item['grupo'];
      final grupoId = grupo['grupo_id'] as int;
      final grupoNome = grupo['nome_grupo'] as String;

      // Adicionar ao mapa de valores
      valoresPorEtapa[etapa] = valor;

      // Agrupar por grupo
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

    // Converter grupos map para entidades
    final grupos = gruposMap.entries.map((entry) {
      final grupoId = entry.key;
      final itens = entry.value;
      final grupoNome = itens.first['grupoNome'];

      // Criar títulos para este grupo
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
      grupos: grupos,
      valoresPorEtapa: valoresPorEtapa,
    );
  }
}
