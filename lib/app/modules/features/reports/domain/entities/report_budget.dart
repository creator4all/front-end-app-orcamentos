import 'package:equatable/equatable.dart';

/// Entidade representando um orçamento na listagem de relatórios.
///
/// Esta classe não tem dependência de JSON, API ou camada de dados.
/// Representa as regras de negócio puras da aplicação.
class ReportBudget extends Equatable {
  final int id;
  final String? nome;
  final String codigo;
  final DateTime dataOrcamento;
  final DateTime? dataValidade;
  final int diasRestantes;
  final double total;
  final String status;
  final bool isArchived;
  final int cidadesCount;
  final int usuarioId; // ID do usuário que criou o orçamento

  const ReportBudget({
    required this.id,
    this.nome,
    required this.codigo,
    required this.dataOrcamento,
    this.dataValidade,
    required this.diasRestantes,
    required this.total,
    required this.status,
    this.isArchived = false,
    this.cidadesCount = 1,
    this.usuarioId = 0,
  });

  /// Verifica se o orçamento está expirado
  bool get isExpired => status.toLowerCase() == 'expirado';

  /// Verifica se o orçamento está aprovado
  bool get isApproved => status.toLowerCase() == 'aprovado';

  /// Verifica se o orçamento está pendente
  bool get isPending => status.toLowerCase() == 'pendente';

  /// Verifica se o orçamento não foi aprovado
  bool get isNotApproved => status.toLowerCase() == 'nao_aprovado';

  @override
  List<Object?> get props => [
        id,
        nome,
        codigo,
        dataOrcamento,
        dataValidade,
        diasRestantes,
        total,
        status,
        isArchived,
        cidadesCount,
        usuarioId,
      ];

  @override
  bool get stringify => true;
}
