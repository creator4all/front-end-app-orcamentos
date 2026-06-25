import 'package:equatable/equatable.dart';

import 'censo_group_entity.dart';

class CensoEscolarEntity extends Equatable {
  final int cidadeId;

  final String cidadeNome;

  final int? censoAno;

  final int? anoPopulacao;

  final List<CensoGroupEntity> grupos;

  final Map<String, double> valoresPorEtapa;

  const CensoEscolarEntity({
    required this.cidadeId,
    required this.cidadeNome,
    this.censoAno,
    this.anoPopulacao,
    required this.grupos,
    required this.valoresPorEtapa,
  });

  /// Grupos ordenados por `grupo_ordem`.
  List<CensoGroupEntity> get gruposOrdenados {
    final ordenados = [...grupos]..sort((a, b) => a.ordem.compareTo(b.ordem));
    return ordenados;
  }

  static String _normalizarNomeGrupo(String nome) => nome.trim().toLowerCase();

  static bool _ehGrupoProfessores(CensoGroupEntity grupo) =>
      _normalizarNomeGrupo(grupo.nome) == 'professores';

  static bool _ehGrupoCursistas(CensoGroupEntity grupo) =>
      _normalizarNomeGrupo(grupo.nome) == 'cursistas';

  double get valorTotal {
    return grupos.fold(0.0, (sum, grupo) => sum + grupo.valorTotal);
  }

  double get valorTotalAlunos {
    return grupos
        .where(
            (grupo) => !_ehGrupoProfessores(grupo) && !_ehGrupoCursistas(grupo))
        .fold(0.0, (sum, grupo) => sum + grupo.valorTotal);
  }

  double get valorTotalProfessores {
    return grupos
        .where(_ehGrupoProfessores)
        .fold(0.0, (sum, grupo) => sum + grupo.valorTotal);
  }

  double get valorTotalCursistas {
    return grupos
        .where(_ehGrupoCursistas)
        .fold(0.0, (sum, grupo) => sum + grupo.valorTotal);
  }

  double? getValorEtapa(String nomeEtapa) {
    return valoresPorEtapa[nomeEtapa];
  }

  double? getValorEtapaProfessores(String nomeEtapa) {
    return valoresPorEtapa['${nomeEtapa}P'];
  }

  double calcularValorLivros(List<String> indicadoresSelecionados) {
    double total = 0.0;

    for (String indicador in indicadoresSelecionados) {
      if (indicador.endsWith('P')) {
        total += getValorEtapaProfessores(indicador) ?? 0.0;
      }
    }

    return total;
  }

  double calcularValorTecnologias(List<String> indicadoresSelecionados) {
    double total = 0.0;

    for (String indicador in indicadoresSelecionados) {
      if (indicador.endsWith('P')) {
        total += getValorEtapaProfessores(indicador) ?? 0.0;
      } else {
        total += getValorEtapa(indicador) ?? 0.0;
      }
    }

    return total;
  }

  @override
  List<Object?> get props =>
      [cidadeId, cidadeNome, censoAno, anoPopulacao, grupos, valoresPorEtapa];

  @override
  String toString() {
    return 'CensoEscolarEntity(cidade: $cidadeNome, grupos: ${grupos.length}, valorTotal: R\$ $valorTotal)';
  }
}
