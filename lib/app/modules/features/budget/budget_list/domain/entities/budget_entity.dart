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
  final bool isArchived;
  final double total;
  final int cidadesCount;
  final bool criadoPorAdmin;
  final int? partnerDestinoId;
  final int? usuarioId;
  final String? usuarioNome;
  final String? empresaRazaoSocial;

  const BudgetEntity({
    required this.id,
    this.nome,
    required this.diasValidade,
    this.dataValidade,
    required this.status,
    this.isArchived = false,
    required this.total,
    required this.cidadesCount,
    this.criadoPorAdmin = false,
    this.partnerDestinoId,
    this.usuarioId,
    this.usuarioNome,
    this.empresaRazaoSocial,
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
        isArchived,
        total,
        cidadesCount,
        criadoPorAdmin,
        partnerDestinoId,
        usuarioId,
        usuarioNome,
        empresaRazaoSocial,
      ];

  @override
  bool get stringify => true;
}
