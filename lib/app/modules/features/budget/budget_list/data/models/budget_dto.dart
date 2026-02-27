import '../../domain/entities/budget_entity.dart';

/// Data Transfer Object para orçamento (Budget)
///
/// Responsável por parsing JSON da API e conversão para Entity
class BudgetDto {
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

  BudgetDto({
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

  /// Factory para criar DTO a partir de JSON da API
  factory BudgetDto.fromJson(Map<String, dynamic> json) {
    final usuarioJson = json['usuario'] as Map<String, dynamic>?;
    final partnerDestinoJson = json['partner_destino'] as Map<String, dynamic>?;
    final cidadesJson = json['cidades'];

    return BudgetDto(
      id: json['id'] as int? ?? 0,
      nome: json['nome'] as String?,
      diasValidade: json['dias_validade'] as int? ?? 0,
      dataValidade: json['data_validade'] != null &&
              (json['data_validade'] as String).isNotEmpty
          ? DateTime.tryParse(json['data_validade'])
          : null,
      status: json['status'] as String? ?? '',
      isArchived: json['is_archived'] as bool? ?? false,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      cidadesCount: cidadesJson is List ? cidadesJson.length : 0,
      criadoPorAdmin: json['criado_por_admin'] as bool? ?? false,
      partnerDestinoId: json['partner_destino_id'] as int?,
      usuarioId: usuarioJson?['id'] as int?,
      usuarioNome: usuarioJson?['nome'] as String?,
      empresaRazaoSocial: partnerDestinoJson?['razao_social'] as String?,
    );
  }

  /// Converte DTO para Entity (camada de domínio)
  BudgetEntity toEntity() {
    return BudgetEntity(
      id: id,
      nome: nome,
      diasValidade: diasValidade,
      dataValidade: dataValidade,
      status: status,
      isArchived: isArchived,
      total: total,
      cidadesCount: cidadesCount,
      criadoPorAdmin: criadoPorAdmin,
      partnerDestinoId: partnerDestinoId,
      usuarioId: usuarioId,
      usuarioNome: usuarioNome,
      empresaRazaoSocial: empresaRazaoSocial,
    );
  }

  /// Converte Entity para DTO (para envio à API)
  factory BudgetDto.fromEntity(BudgetEntity entity) {
    return BudgetDto(
      id: entity.id,
      nome: entity.nome,
      diasValidade: entity.diasValidade,
      dataValidade: entity.dataValidade,
      status: entity.status,
      isArchived: entity.isArchived,
      total: entity.total,
      cidadesCount: entity.cidadesCount,
      criadoPorAdmin: entity.criadoPorAdmin,
      partnerDestinoId: entity.partnerDestinoId,
      usuarioId: entity.usuarioId,
      usuarioNome: entity.usuarioNome,
      empresaRazaoSocial: entity.empresaRazaoSocial,
    );
  }

  /// Converte DTO para JSON (para envio à API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'dias_validade': diasValidade,
      'data_validade': dataValidade?.toIso8601String(),
      'status': status,
      'is_archived': isArchived,
      'total': total,
      'criado_por_admin': criadoPorAdmin,
      'partner_destino_id': partnerDestinoId,
      'usuario': usuarioId != null
          ? {
              'id': usuarioId,
              'nome': usuarioNome,
            }
          : null,
      'partner_destino': empresaRazaoSocial != null
          ? {'razao_social': empresaRazaoSocial}
          : null,
    };
  }
}
