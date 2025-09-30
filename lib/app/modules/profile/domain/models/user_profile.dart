class UserProfile {
  final int id;
  final String name;
  final String email;
  final String? cargo;
  final String? phone;
  final String? avatar;
  final String? roleName;
  final String? partnerName;
  final bool status;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.cargo,
    this.phone,
    this.avatar,
    this.roleName,
    this.partnerName,
    required this.status,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    // Extrair nome da role do objeto aninhado
    String? roleName;
    if (map['role'] != null && map['role'] is Map) {
      roleName = map['role']['rol_name'];
    }
    
    // Extrair nome do parceiro do objeto aninhado
    String? partnerName;
    if (map['partner'] != null && map['partner'] is Map) {
      partnerName = map['partner']['par_trade_name'] ?? map['partner']['par_legal_name'];
    }
    
    return UserProfile(
      id: map['usr_userId'] ?? 0,
      name: map['usr_name'] ?? '',
      email: map['usr_email'] ?? '',
      cargo: map['usr_cargo'],
      phone: map['usr_phone'],
      avatar: map['usr_avatar'],
      roleName: roleName,
      partnerName: partnerName,
      status: map['usr_status'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usr_name': name,
      'usr_email': email,
      'usr_cargo': cargo,
      'usr_phone': phone,
    };
  }

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? cargo,
    String? phone,
    String? avatar,
    String? roleName,
    String? partnerName,
    bool? status,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      cargo: cargo ?? this.cargo,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      roleName: roleName ?? this.roleName,
      partnerName: partnerName ?? this.partnerName,
      status: status ?? this.status,
    );
  }
}
