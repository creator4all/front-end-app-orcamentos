import 'package:equatable/equatable.dart';

import 'censo_group_entity.dart';

class CensoEscolarEntity extends Equatable {
  final int cidadeId;

  final String cidadeNome;

  final int? censoAno;

  final List<CensoGroupEntity> grupos;

  final Map<String, double> valoresPorEtapa;

  const CensoEscolarEntity({
    required this.cidadeId,
    required this.cidadeNome,
    this.censoAno,
    required this.grupos,
    required this.valoresPorEtapa,
  });

  double get valorTotal {
    return grupos.fold(0.0, (sum, grupo) => sum + grupo.valorTotal);
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
      [cidadeId, cidadeNome, censoAno, grupos, valoresPorEtapa];

  @override
  String toString() {
    return 'CensoEscolarEntity(cidade: $cidadeNome, grupos: ${grupos.length}, valorTotal: R\$ $valorTotal)';
  }
}
