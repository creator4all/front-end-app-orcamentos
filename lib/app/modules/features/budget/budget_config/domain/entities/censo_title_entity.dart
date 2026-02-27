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

  const CensoTitleEntity({
    required this.id,
    required this.nomeEtapa,
    required this.tituloExibicao,
    required this.valor,
    required this.isProfessores,
    required this.grupoId,
  });

  /// Formata o valor para exibição
  String get valorFormatado {
    return valor.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  List<Object?> get props =>
      [id, nomeEtapa, tituloExibicao, valor, isProfessores, grupoId];

  @override
  String toString() {
    return 'CensoTitleEntity(id: $id, nome: $tituloExibicao, valor: $valor, professores: $isProfessores)';
  }
}
