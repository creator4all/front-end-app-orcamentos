import 'package:equatable/equatable.dart';

/// Entidade pura de domínio representando um orçamento (Budget)
///
/// Esta classe não tem dependência de JSON, API ou camada de dados.
/// Representa as regras de negócio puras da aplicação.
class BudgetEntity extends Equatable {
  final int id;
  final String? nome;
  final int diasValidade;
  final DateTime? dataValidade;
  final String status;
  final double total;
  final int cidadesCount;

  const BudgetEntity({
    required this.id,
    this.nome,
    required this.diasValidade,
    this.dataValidade,
    required this.status,
    required this.total,
    required this.cidadesCount,
  });

  /// Calcula se o orçamento está expirado
  bool get isExpired {
    if (dataValidade == null) return false;
    return DateTime.now().isAfter(dataValidade!);
  }

  /// Calcula dias restantes até expiração
  int get daysRemaining {
    if (dataValidade == null) return 0;
    final difference = dataValidade!.difference(DateTime.now()).inDays;
    return difference > 0 ? difference : 0;
  }

  /// Verifica se o orçamento está arquivado
  bool get isArchived => status.toLowerCase() == 'arquivado';

  /// Verifica se o orçamento está aprovado
  bool get isApproved => status.toLowerCase() == 'aprovado';

  /// Verifica se o orçamento está pendente
  bool get isPending => status.toLowerCase() == 'pendente';

  @override
  List<Object?> get props => [
        id,
        nome,
        diasValidade,
        dataValidade,
        status,
        total,
        cidadesCount,
      ];

  @override
  String toString() {
    return 'BudgetEntity(id: $id, nome: $nome, status: $status, total: $total)';
  }
}
