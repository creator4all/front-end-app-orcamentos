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
  final double total;
  final int cidadesCount;

  BudgetDto({
    required this.id,
    this.nome,
    required this.diasValidade,
    this.dataValidade,
    required this.status,
    required this.total,
    required this.cidadesCount,
  });

  /// Factory para criar DTO a partir de JSON da API
  factory BudgetDto.fromJson(Map<String, dynamic> json) {
    return BudgetDto(
      id: (json['id'] ?? 0) is String
          ? int.tryParse(json['id']) ?? 0
          : (json['id'] ?? 0) as int,
      nome: json['nome'] as String?,
      diasValidade: (json['dias_validade'] ?? 0) is String
          ? int.tryParse(json['dias_validade']) ?? 0
          : (json['dias_validade'] ?? 0) as int,
      dataValidade: json['data_validade'] != null &&
              (json['data_validade'] as String).isNotEmpty
          ? DateTime.tryParse(json['data_validade'])
          : null,
      status: (json['status'] ?? '').toString(),
      total: (json['total'] is int)
          ? (json['total'] as int).toDouble()
          : (json['total'] as num?)?.toDouble() ?? 0.0,
      cidadesCount: (json['cidades'] ?? 0) is String
          ? int.tryParse(json['cidades']) ?? 0
          : (json['cidades'] ?? 0) as int,
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
      total: total,
      cidadesCount: cidadesCount,
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
      total: entity.total,
      cidadesCount: entity.cidadesCount,
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
      'total': total,
      'cidades': cidadesCount,
    };
  }
}
