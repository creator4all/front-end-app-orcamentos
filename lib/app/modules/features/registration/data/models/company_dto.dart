import '../../domain/entities/company.dart';

/// DTO para parsing da resposta de verificação de documento
class CompanyDto {
  final int partnerId;
  final String legalName;
  final String tradeName;
  final String email;
  final String phone;
  final String cnpj;

  const CompanyDto({
    required this.partnerId,
    required this.legalName,
    required this.tradeName,
    required this.email,
    required this.phone,
    required this.cnpj,
  });

  factory CompanyDto.fromJson(Map<String, dynamic> json) {
    return CompanyDto(
      partnerId: json['par_partnerId'] ?? 0,
      legalName: json['par_legal_name'] ?? '',
      tradeName: json['par_trade_name'] ?? '',
      email: json['par_email'] ?? '',
      phone: json['par_phone'] ?? '',
      cnpj: json['par_cnpj'] ?? '',
    );
  }

  Company toEntity() => Company(
        id: partnerId,
        legalName: legalName,
        tradeName: tradeName,
        email: email,
        phone: phone,
        cnpj: cnpj,
        status: true,
      );
}

/// Response wrapper para a rota de verificação de documento
/// A API retorna: { "dados": { "existe": true, "empresa": {...} } }
class VerifyDocumentResponse {
  final bool existe;
  final CompanyDto? empresa;

  const VerifyDocumentResponse({
    required this.existe,
    this.empresa,
  });

  factory VerifyDocumentResponse.fromJson(Map<String, dynamic> json) {
    final data = json['dados'] as Map<String, dynamic>;

    return VerifyDocumentResponse(
      existe: data['existe'] ?? false,
      empresa:
          data['empresa'] != null ? CompanyDto.fromJson(data['empresa']) : null,
    );
  }
}
