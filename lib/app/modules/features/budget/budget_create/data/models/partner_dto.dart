import '../../domain/entities/partner_entity.dart';

/// Data Transfer Object para Parceiro
/// Responsável pela serialização/deserialização de JSON
class PartnerDto {
  final int id;
  final String name;
  final String? cnpj;
  final String? logo;
  final bool isActive;

  const PartnerDto({
    required this.id,
    required this.name,
    this.cnpj,
    this.logo,
    this.isActive = true,
  });

  /// Cria DTO a partir de JSON da API
  factory PartnerDto.fromJson(Map<String, dynamic> json) {
    return PartnerDto(
      id: (json['par_partnerId'] as num?)?.toInt() ?? 0,
      name: json['par_legal_name'] as String? ?? '',
      cnpj: json['par_cnpj'] as String?,
      logo: json['par_logo'] as String?,
      isActive: _parseActive(json['par_status'] ?? true),
    );
  }

  /// Parse de status ativo (pode vir como bool, int ou string)
  static bool _parseActive(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value == '1' ||
          value.toLowerCase() == 'true' ||
          value.toLowerCase() == 'ativo';
    }
    return true;
  }

  /// Converte DTO para Entity
  PartnerEntity toEntity() {
    return PartnerEntity(
      id: id,
      name: name,
      cnpj: cnpj,
      logo: logo,
      isActive: isActive,
    );
  }

  /// Cria DTO a partir de Entity
  factory PartnerDto.fromEntity(PartnerEntity entity) {
    return PartnerDto(
      id: entity.id,
      name: entity.name,
      cnpj: entity.cnpj,
      logo: entity.logo,
      isActive: entity.isActive,
    );
  }

  /// Converte DTO para JSON
  Map<String, dynamic> toJson() {
    return {
      'par_partnerId': id,
      'par_legal_name': name,
      'par_cnpj': cnpj,
      'par_logo': logo,
      'par_status': isActive,
    };
  }

  /// Cria uma lista de entities a partir de uma lista JSON
  static List<PartnerEntity> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => PartnerDto.fromJson(json as Map<String, dynamic>))
        .map((dto) => dto.toEntity())
        .toList();
  }
}
