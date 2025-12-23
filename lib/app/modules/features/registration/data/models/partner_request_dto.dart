import '../../domain/entities/partner_request.dart';

/// DTO para envio de solicitação de parceria (prospecção)
class PartnerRequestDto {
  final String name;
  final String email;
  final String phone;
  final String? company;
  final String? cnpj;
  final PublicSectorExperience publicSectorExperience;

  const PartnerRequestDto({
    required this.name,
    required this.email,
    required this.phone,
    this.company,
    this.cnpj,
    required this.publicSectorExperience,
  });

  /// Cria DTO a partir da entidade
  factory PartnerRequestDto.fromEntity(PartnerRequest entity) {
    return PartnerRequestDto(
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      company: entity.company,
      cnpj: entity.cnpj,
      publicSectorExperience: entity.publicSectorExperience,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prp_nome': name,
      'prp_email': email,
      'prp_telefone': phone,
      'prp_empresa': company,
      'prp_documento': cnpj,
      'prp_is_contatado': false,
      'prp_experiencia_vendas_publicas': publicSectorExperience.value,
    };
  }
}
