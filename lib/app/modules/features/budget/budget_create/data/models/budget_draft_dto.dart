import '../../domain/entities/budget_draft_entity.dart';
import '../../domain/entities/location_entity.dart';

/// Data Transfer Object para Orçamento em Rascunho
/// Responsável pela serialização/deserialização de JSON
class BudgetDraftDto {
  final int id;
  final int partnerId;
  final String partnerName;
  final String stateCode;
  final String stateName;
  final String cityCode;
  final String cityName;
  final String? responsibleName;
  final String? responsibleEmail;
  final DateTime? validityDate;
  final String status;
  final DateTime createdAt;
  final int createdByUserId;

  const BudgetDraftDto({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    required this.stateCode,
    required this.stateName,
    required this.cityCode,
    required this.cityName,
    this.responsibleName,
    this.responsibleEmail,
    this.validityDate,
    required this.status,
    required this.createdAt,
    required this.createdByUserId,
  });

  /// Cria DTO a partir de JSON da API
  factory BudgetDraftDto.fromJson(Map<String, dynamic> json) {
    return BudgetDraftDto(
      id: json['orc_id'] as int,
      partnerId: json['orc_parceiro_id'] as int,
      partnerName: json['parceiro_nome'] as String? ??
          json['orc_parceiro_nome'] as String? ??
          '',
      stateCode: json['orc_estado'] as String,
      stateName: json['estado_nome'] as String? ??
          json['orc_estado_nome'] as String? ??
          '',
      cityCode: json['orc_cidade'] as String,
      cityName: json['cidade_nome'] as String? ??
          json['orc_cidade_nome'] as String? ??
          '',
      responsibleName: json['orc_responsavel_nome'] as String?,
      responsibleEmail: json['orc_responsavel_email'] as String?,
      validityDate: _parseDate(json['orc_validade']),
      status: json['orc_status'] as String,
      createdAt: _parseDate(json['orc_criado_em']) ?? DateTime.now(),
      createdByUserId: json['orc_criado_por_usuario_id'] as int? ??
          json['orc_usuario_id'] as int? ??
          0,
    );
  }

  /// Parse de data (pode vir em diferentes formatos)
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Converte DTO para Entity
  BudgetDraftEntity toEntity() {
    return BudgetDraftEntity(
      id: id,
      partnerId: partnerId,
      partnerName: partnerName,
      location: LocationEntity(
        stateCode: stateCode,
        stateName: stateName,
        cityCode: cityCode,
        cityName: cityName,
      ),
      responsibleName: responsibleName,
      responsibleEmail: responsibleEmail,
      validityDate: validityDate,
      status: status,
      createdAt: createdAt,
      createdByUserId: createdByUserId,
    );
  }

  /// Cria DTO a partir de Entity
  factory BudgetDraftDto.fromEntity(BudgetDraftEntity entity) {
    return BudgetDraftDto(
      id: entity.id,
      partnerId: entity.partnerId,
      partnerName: entity.partnerName,
      stateCode: entity.location.stateCode,
      stateName: entity.location.stateName,
      cityCode: entity.location.cityCode,
      cityName: entity.location.cityName,
      responsibleName: entity.responsibleName,
      responsibleEmail: entity.responsibleEmail,
      validityDate: entity.validityDate,
      status: entity.status,
      createdAt: entity.createdAt,
      createdByUserId: entity.createdByUserId,
    );
  }

  /// Converte DTO para JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'orc_id': id,
      'orc_parceiro_id': partnerId,
      'orc_estado': stateCode,
      'orc_cidade': cityCode,
      'orc_status': status,
      'orc_criado_em': createdAt.toIso8601String(),
      'orc_criado_por_usuario_id': createdByUserId,
    };

    if (responsibleName != null) {
      data['orc_responsavel_nome'] = responsibleName;
    }
    if (responsibleEmail != null) {
      data['orc_responsavel_email'] = responsibleEmail;
    }
    if (validityDate != null) {
      data['orc_validade'] = validityDate!.toIso8601String().split('T')[0];
    }

    return data;
  }
}
