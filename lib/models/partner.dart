import 'package:flutter/foundation.dart';

class Partner {
  final String cnpj;
  final String fantasyName;
  final String companyName;
  final String? logo;
  final bool status;

  Partner({
    required this.cnpj,
    required this.fantasyName,
    required this.companyName,
    this.logo,
    this.status = true,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      cnpj: json['cnpj'] ?? '',
      fantasyName: json['fantasyName'] ?? '',
      companyName: json['companyName'] ?? '',
      logo: json['logo'],
      status: json['status'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cnpj': cnpj,
      'fantasyName': fantasyName,
      'companyName': companyName,
      'logo': logo,
      'status': status,
    };
  }
}
