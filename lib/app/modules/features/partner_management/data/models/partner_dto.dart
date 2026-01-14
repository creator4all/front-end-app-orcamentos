import '../../domain/entities/partner.dart';

/// DTO para parsing do JSON de parceiro da API
class PartnerDto {
  final int id;
  final String legalName;
  final String tradeName;
  final String email;
  final String? phone;
  final String cnpj;
  final bool status;

  PartnerDto({
    required this.id,
    required this.legalName,
    required this.tradeName,
    required this.email,
    this.phone,
    required this.cnpj,
    required this.status,
  });

  /// Cria DTO a partir do JSON da API
  /// GET /api/partners
  factory PartnerDto.fromJson(Map<String, dynamic> json) {
    return PartnerDto(
      id: json['par_partnerId'] ?? 0,
      legalName: json['par_legal_name'] ?? '',
      tradeName: json['par_trade_name'] ?? '',
      email: json['par_email'] ?? '',
      phone: json['par_phone'],
      cnpj: json['par_cnpj'] ?? '',
      status: json['par_status'] == true || json['par_status'] == 1,
    );
  }

  /// Converte DTO para entidade de domínio
  Partner toEntity() {
    return Partner(
      id: id,
      legalName: legalName,
      tradeName: tradeName,
      email: email,
      phone: phone,
      cnpj: cnpj,
      status: status,
    );
  }
}

/// DTO para parsing da resposta paginada da API
class PaginatedPartnersDto {
  final List<PartnerDto> partners;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  PaginatedPartnersDto({
    required this.partners,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  /// Cria DTO a partir do JSON da API
  factory PaginatedPartnersDto.fromJson(Map<String, dynamic> json) {
    final dados = json['dados'] ?? json;
    final List<dynamic> dataList = dados['data'] ?? [];
    final pagination = dados['pagination'] ?? {};

    return PaginatedPartnersDto(
      partners: dataList.map((e) => PartnerDto.fromJson(e)).toList(),
      currentPage: pagination['current_page'] ?? 1,
      perPage: pagination['per_page'] ?? 15,
      total: pagination['total'] ?? 0,
      lastPage: pagination['last_page'] ?? 1,
    );
  }

  /// Converte DTO para entidade de domínio
  PaginatedPartners toEntity() {
    return PaginatedPartners(
      partners: partners.map((dto) => dto.toEntity()).toList(),
      currentPage: currentPage,
      perPage: perPage,
      total: total,
      lastPage: lastPage,
    );
  }
}
