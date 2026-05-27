import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';

part 'censo_title_entity.g.dart';

/// Entidade que representa um título/etapa do censo escolar
/// Ex: "1º Ano", "2º Ano", "1º Ano P" (Professores)
@CopyWith()
class CensoTitleEntity extends Equatable {
  /// ID do título/etapa
  final int id;

  /// Nome da etapa (ex: "ef1ano", "ef2anoP")
  final String nomeEtapa;

  /// Nome para exibição (ex: "1º Ano", "2º Ano - Professores")
  final String tituloExibicao;

  /// Valor do censo para esta etapa
  final double valor;

  /// Indica se é referente a professores (sufixo P)
  final bool isProfessores;

  /// ID do grupo ao qual pertence
  final int grupoId;

  /// Fração da população aplicada (ex.: 0.005 = 0,5%). Null quando não aplicável.
  final double? percentualPopulacao;

  const CensoTitleEntity({
    required this.id,
    required this.nomeEtapa,
    required this.tituloExibicao,
    required this.valor,
    required this.isProfessores,
    required this.grupoId,
    this.percentualPopulacao,
  });

  /// Formata o valor para exibição
  String get valorFormatado {
    return valor.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  /// Label de exibição com percentual quando aplicável
  String get labelComPercentual {
    if (percentualPopulacao == null) {
      return tituloExibicao;
    }
    if (percentualPopulacao! >= 0 && percentualPopulacao! <= 1) {
      final pct = percentualPopulacao! * 100;
      final pctStr = pct == 0
          ? '0'
          : pct == 100
              ? '100'
              : pct.toStringAsFixed(1).replaceAll('.', ',');
      return '$tituloExibicao ($pctStr%)';
    }
    return tituloExibicao;
  }

  @override
  List<Object?> get props => [
        id,
        nomeEtapa,
        tituloExibicao,
        valor,
        isProfessores,
        grupoId,
        percentualPopulacao
      ];

  @override
  String toString() {
    return 'CensoTitleEntity(id: $id, nome: $tituloExibicao, valor: $valor, professores: $isProfessores)';
  }
}
