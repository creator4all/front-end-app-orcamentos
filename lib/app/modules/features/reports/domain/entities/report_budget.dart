import 'package:equatable/equatable.dart';

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
  final int usuarioId;

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

  bool get isExpired => status.toLowerCase() == 'expirado';

  bool get isApproved => status.toLowerCase() == 'aprovado';

  bool get isPending => status.toLowerCase() == 'pendente';

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
