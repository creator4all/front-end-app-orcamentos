import 'package:equatable/equatable.dart';

import 'censo_group_entity.dart';

/// Entidade que representa o censo escolar completo de uma cidade
class CensoEscolarEntity extends Equatable {
  /// ID da cidade
  final int cidadeId;

  /// Nome da cidade
  final String cidadeNome;

  /// Ano de referência do censo
  final int? censoAno;

  /// Grupos do censo (Infantil, Ensino Fundamental, EJA, etc.)
  final List<CensoGroupEntity> grupos;

  /// Mapa rápido para lookup de valores por nome da etapa
  final Map<String, double> valoresPorEtapa;

  const CensoEscolarEntity({
    required this.cidadeId,
    required this.cidadeNome,
    this.censoAno,
    required this.grupos,
    required this.valoresPorEtapa,
  });

  /// Valor total do censo (soma de todos os grupos)
  double get valorTotal {
    return grupos.fold(0.0, (sum, grupo) => sum + grupo.valorTotal);
  }

  /// Busca valor de uma etapa específica pelo nome
  double? getValorEtapa(String nomeEtapa) {
    return valoresPorEtapa[nomeEtapa];
  }

  /// Busca valor de uma etapa de professores (com sufixo P)
  double? getValorEtapaProfessores(String nomeEtapa) {
    return valoresPorEtapa['${nomeEtapa}P'];
  }

  /// Calcula valor para produtos do tipo LIVRO
  /// Soma apenas indicadores de professores (com sufixo P)
  double calcularValorLivros(List<String> indicadoresSelecionados) {
    double total = 0.0;

    for (String indicador in indicadoresSelecionados) {
      // Para livros, consideramos apenas indicadores de professores
      if (indicador.endsWith('P')) {
        total += getValorEtapaProfessores(indicador) ?? 0.0;
      }
    }

    return total;
  }

  /// Calcula valor para produtos do tipo TECNOLOGIA
  /// Soma todos os indicadores (alunos + professores)
  double calcularValorTecnologias(List<String> indicadoresSelecionados) {
    double total = 0.0;

    for (String indicador in indicadoresSelecionados) {
      // Para tecnologias, somamos todos os indicadores
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
