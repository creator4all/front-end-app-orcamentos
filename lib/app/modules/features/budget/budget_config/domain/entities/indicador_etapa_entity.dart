import 'package:equatable/equatable.dart';

/// Entidade que representa um indicador de etapa educacional
///
/// Exemplo: "Pré-escola", "Ensino Fundamental", "Ensino Médio", etc.
class IndicadorEtapaEntity extends Equatable {
  /// ID do relacionamento produto_indicador
  final int produtoIndicadorId;

  /// ID do indicador
  final int indicadorId;

  /// Nome do indicador (ex: "Pré-escola")
  final String indicadorNome;

  /// Nome da etapa (ex: "ef1ano", "ef2anoP")
  final String nomeEtapa;

  /// ID do grupo ao qual o indicador pertence
  final int grupoId;

  /// Nome do grupo (ex: "Etapas de Ensino")
  final String grupoNome;

  /// Se o indicador está selecionado para este produto
  final bool selecionado;

  /// Indica se este é o valor padrão do indicador para o produto
  final bool? valorPadrao;

  const IndicadorEtapaEntity({
    required this.produtoIndicadorId,
    required this.indicadorId,
    required this.indicadorNome,
    required this.nomeEtapa,
    required this.grupoId,
    required this.grupoNome,
    required this.selecionado,
    this.valorPadrao,
  });

  @override
  List<Object?> get props => [
        produtoIndicadorId,
        indicadorId,
        indicadorNome,
        nomeEtapa,
        grupoId,
        grupoNome,
        selecionado,
        valorPadrao,
      ];

  /// Cria uma cópia com campos alterados
  IndicadorEtapaEntity copyWith({
    int? produtoIndicadorId,
    int? indicadorId,
    String? indicadorNome,
    String? nomeEtapa,
    int? grupoId,
    String? grupoNome,
    bool? selecionado,
  }) {
    return IndicadorEtapaEntity(
      produtoIndicadorId: produtoIndicadorId ?? this.produtoIndicadorId,
      indicadorId: indicadorId ?? this.indicadorId,
      indicadorNome: indicadorNome ?? this.indicadorNome,
      nomeEtapa: nomeEtapa ?? this.nomeEtapa,
      grupoId: grupoId ?? this.grupoId,
      grupoNome: grupoNome ?? this.grupoNome,
      selecionado: selecionado ?? this.selecionado,
      valorPadrao: valorPadrao, // Valor padrão não é alterável via copyWith
    );
  }

  @override
  String toString() {
    return 'IndicadorEtapaEntity(nomeEtapa: $nomeEtapa, grupoNome: $grupoNome, selecionado: $selecionado)';
  }
}
