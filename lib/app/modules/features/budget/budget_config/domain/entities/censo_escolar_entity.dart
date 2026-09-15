import 'package:equatable/equatable.dart';

import 'censo_group_entity.dart';

class CensoEscolarEntity extends Equatable {
  final int cidadeId;

  final String cidadeNome;

  final int? censoAno;

  final int? anoPopulacao;

  /// Maior ano de censo quando a visão agrega cidades com anos diferentes.
  ///
  /// Null quando todas as cidades compartilham o mesmo ano — nesse caso
  /// [censoAno] sozinho já descreve o conjunto.
  final int? censoAnoFinal;

  /// Maior ano-base de população quando as cidades agregadas divergem.
  final int? anoPopulacaoFinal;

  final List<CensoGroupEntity> grupos;

  final Map<String, double> valoresPorEtapa;

  const CensoEscolarEntity({
    required this.cidadeId,
    required this.cidadeNome,
    this.censoAno,
    this.anoPopulacao,
    this.censoAnoFinal,
    this.anoPopulacaoFinal,
    required this.grupos,
    required this.valoresPorEtapa,
  });

  /// Ano do censo para exibição: `2025` quando único, `2025–2026` quando as
  /// cidades agregadas divergem, `null` quando nenhuma cidade informou o ano.
  String? get censoAnoLabel => _rotuloAno(censoAno, censoAnoFinal);

  /// Ano-base da população para exibição, com a mesma regra de [censoAnoLabel].
  String? get anoPopulacaoLabel => _rotuloAno(anoPopulacao, anoPopulacaoFinal);

  static String? _rotuloAno(int? inicio, int? fim) {
    if (inicio == null) return null;
    if (fim == null || fim == inicio) return inicio.toString();
    return '$inicio–$fim';
  }

  /// Deriva o par (menor, maior) de uma lista de anos, ignorando nulos.
  ///
  /// Devolve `(null, null)` quando nenhuma cidade informou o ano e
  /// `(ano, null)` quando todas informaram o mesmo — assim o rótulo não vira
  /// um intervalo degenerado do tipo `2025–2025`.
  static (int?, int?) faixaDeAnos(Iterable<int?> anos) {
    final validos = anos.whereType<int>().toList()..sort();
    if (validos.isEmpty) return (null, null);
    final menor = validos.first;
    final maior = validos.last;
    return (menor, menor == maior ? null : maior);
  }

  /// Grupos ordenados por `grupo_ordem`, com os índices de cada grupo
  /// ordenados por `ind_ordem`.
  ///
  /// A ordenação é exclusivamente pelos campos de ordem vindos da API — nunca
  /// pelo texto do título. Quando um contrato não envia a ordem, todos os
  /// valores empatam em [FractionalOrder.zero] e o `sort` estável preserva a
  /// ordem de chegada do payload.
  List<CensoGroupEntity> get gruposOrdenados {
    final ordenados = [...grupos]..sort((a, b) => a.ordem.compareTo(b.ordem));
    return [
      for (final grupo in ordenados)
        grupo.copyWith(
          titulos: [...grupo.titulos]
            ..sort((a, b) => a.ordem.compareTo(b.ordem)),
        ),
    ];
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
  List<Object?> get props => [
        cidadeId,
        cidadeNome,
        censoAno,
        anoPopulacao,
        censoAnoFinal,
        anoPopulacaoFinal,
        grupos,
        valoresPorEtapa,
      ];

  @override
  String toString() {
    return 'CensoEscolarEntity(cidade: $cidadeNome, grupos: ${grupos.length}, valorTotal: R\$ $valorTotal)';
  }
}
