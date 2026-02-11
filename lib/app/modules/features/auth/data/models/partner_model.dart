import 'package:copy_with_extension/copy_with_extension.dart';

import '../../domain/entities/partner.dart';

part 'partner_model.g.dart';

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

  /// Chaves conforme contrato do backend (`GET /api/perfil/me` → campo `partner`)
  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['par_partnerId'] as int,
      legalName: json['par_legal_name'] as String,
      tradeName: json['par_trade_name'] as String,
      email: json['par_email'] as String? ?? '',
      phone: json['par_phone'] as String,
      logo: json['par_logo'] as String?,
      cnpj: json['par_cnpj'] as String,
      status: json['par_status'] as bool? ?? false,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  /// Chaves alinhadas com a API para garantir round-trip do cache local
  Map<String, dynamic> toJson() {
    return {
      'par_partnerId': id,
      'par_legal_name': legalName,
      'par_trade_name': tradeName,
      'par_email': email,
      'par_phone': phone,
      'par_logo': logo,
      'par_cnpj': cnpj,
      'par_status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

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
