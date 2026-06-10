class PartnerProfile {
  final int id;
  final String legalName;
  final String tradeName;
  final String? email;
  final String phone;
  final String? logo;
  final String? logoBase64;
  final String cnpj;
  final bool status;
  final String? url;
  final String? contractStoragePath;
  final String? contractFileName;
  final String? contractMimeType;
  final int? contractSize;
  final DateTime? contractUploadedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasContract => contractStoragePath != null && contractFileName != null;

  PartnerProfile({
    required this.id,
    required this.legalName,
    required this.tradeName,
    this.email,
    required this.phone,
    this.logo,
    this.logoBase64,
    required this.cnpj,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.url,
    this.contractStoragePath,
    this.contractFileName,
    this.contractMimeType,
    this.contractSize,
    this.contractUploadedAt,
  });

  factory PartnerProfile.fromMap(Map<String, dynamic> map) {
    return PartnerProfile(
      id: map['par_partnerId'] ?? 0,
      legalName: map['par_legal_name'] ?? '',
      tradeName: map['par_trade_name'] ?? '',
      email: map['par_email'],
      phone: map['par_phone'] ?? '',
      logo: map['par_logo'],
      logoBase64: map['par_logo_base64'],
      cnpj: map['par_cnpj'] ?? '',
      status: map['par_status'] == 1 || map['par_status'] == true,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'])
          : null,
      url: map['par_url'],
      contractStoragePath: map['par_contract_storage_path'],
      contractFileName: map['par_contract_file_name'],
      contractMimeType: map['par_contract_mime_type'],
      contractSize: map['par_contract_size'],
      contractUploadedAt: map['par_contract_uploaded_at'] != null
          ? DateTime.tryParse(map['par_contract_uploaded_at'])
          : null,
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
      'par_logo_base64': logoBase64,
      'par_cnpj': cnpj,
      'par_status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'par_url': url,
      'par_contract_storage_path': contractStoragePath,
      'par_contract_file_name': contractFileName,
      'par_contract_mime_type': contractMimeType,
      'par_contract_size': contractSize,
      'par_contract_uploaded_at': contractUploadedAt?.toIso8601String(),
    };
  }

  PartnerProfile copyWith({
    int? id,
    String? legalName,
    String? tradeName,
    String? email,
    String? phone,
    String? logo,
    String? logoBase64,
    String? cnpj,
    bool? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? url,
    String? contractStoragePath,
    String? contractFileName,
    String? contractMimeType,
    int? contractSize,
    DateTime? contractUploadedAt,
  }) {
    return PartnerProfile(
      id: id ?? this.id,
      legalName: legalName ?? this.legalName,
      tradeName: tradeName ?? this.tradeName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      logo: logo ?? this.logo,
      logoBase64: logoBase64 ?? this.logoBase64,
      cnpj: cnpj ?? this.cnpj,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      url: url ?? this.url,
      contractStoragePath: contractStoragePath ?? this.contractStoragePath,
      contractFileName: contractFileName ?? this.contractFileName,
      contractMimeType: contractMimeType ?? this.contractMimeType,
      contractSize: contractSize ?? this.contractSize,
      contractUploadedAt: contractUploadedAt ?? this.contractUploadedAt,
    );
  }
}
