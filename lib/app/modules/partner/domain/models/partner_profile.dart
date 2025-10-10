class PartnerProfile {
  final int id;
  final String legalName;
  final String tradeName;
  final String? email;
  final String phone;
  final String? logo;
  final String cnpj;
  final bool status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PartnerProfile({
    required this.id,
    required this.legalName,
    required this.tradeName,
    this.email,
    required this.phone,
    this.logo,
    required this.cnpj,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory PartnerProfile.fromMap(Map<String, dynamic> map) {
    return PartnerProfile(
      id: map['par_partnerId'] ?? 0,
      legalName: map['par_legal_name'] ?? '',
      tradeName: map['par_trade_name'] ?? '',
      email: map['par_email'],
      phone: map['par_phone'] ?? '',
      logo: map['par_logo'],
      cnpj: map['par_cnpj'] ?? '',
      status: map['par_status'] == 1 || map['par_status'] == true,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'par_partnerId': id,
      'par_legal_name': legalName,
      'par_trade_name': tradeName,
      'par_email': email,
      'par_phone': phone,
      'par_logo': logo,
      'par_cnpj': cnpj,
      'par_status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PartnerProfile copyWith({
    int? id,
    String? legalName,
    String? tradeName,
    String? email,
    String? phone,
    String? logo,
    String? cnpj,
    bool? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PartnerProfile(
      id: id ?? this.id,
      legalName: legalName ?? this.legalName,
      tradeName: tradeName ?? this.tradeName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      logo: logo ?? this.logo,
      cnpj: cnpj ?? this.cnpj,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
