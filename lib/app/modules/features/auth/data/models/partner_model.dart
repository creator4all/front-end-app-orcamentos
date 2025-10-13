import 'package:copy_with_extension/copy_with_extension.dart';

import '../../domain/entities/partner.dart';

part 'partner_model.g.dart';

/// Model de dados (DTO) para Partner
/// Responsável por serialização/deserialização JSON e conversão para Entity
@CopyWith()
class PartnerModel {
  final int id;
  final String legalName;
  final String tradeName;
  final String email;
  final String phone;
  final String? logo;
  final String cnpj;
  final bool status;
  final String? createdAt;
  final String? updatedAt;

  const PartnerModel({
    required this.id,
    required this.legalName,
    required this.tradeName,
    required this.email,
    required this.phone,
    this.logo,
    required this.cnpj,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  /// Cria um PartnerModel a partir de JSON da API
  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['par_partnerId'] ?? json['id'] ?? 0,
      legalName: json['par_legal_name'] ?? json['legal_name'] ?? '',
      tradeName: json['par_trade_name'] ?? json['trade_name'] ?? '',
      email: json['par_email'] ?? json['email'] ?? '',
      phone: json['par_phone'] ?? json['phone'] ?? '',
      logo: json['par_logo'] ?? json['logo'],
      cnpj: json['par_cnpj'] ?? json['cnpj'] ?? '',
      status: json['par_status'] ?? json['status'] ?? false,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  /// Converte PartnerModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'legal_name': legalName,
      'trade_name': tradeName,
      'email': email,
      'phone': phone,
      'logo': logo,
      'cnpj': cnpj,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Converte PartnerModel para Entity (Domain)
  Partner toEntity() {
    return Partner(
      id: id,
      legalName: legalName,
      tradeName: tradeName,
      email: email,
      phone: phone,
      logo: logo,
      cnpj: cnpj,
      status: status,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    );
  }

  /// Cria PartnerModel a partir de Entity (Domain)
  factory PartnerModel.fromEntity(Partner partner) {
    return PartnerModel(
      id: partner.id,
      legalName: partner.legalName,
      tradeName: partner.tradeName,
      email: partner.email,
      phone: partner.phone,
      logo: partner.logo,
      cnpj: partner.cnpj,
      status: partner.status,
      createdAt: partner.createdAt?.toIso8601String(),
      updatedAt: partner.updatedAt?.toIso8601String(),
    );
  }

  @override
  String toString() {
    return 'PartnerModel(id: $id, legalName: $legalName, tradeName: $tradeName, cnpj: $cnpj)';
  }
}
