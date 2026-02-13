import '../../domain/entities/user_profile.dart';

class UserProfileModel {
  final int id;
  final String name;
  final String email;
  final String? cargo;
  final String? phone;
  final String? avatar;
  final String? avatarBase64;
  final String? roleName;
  final String? partnerName;
  final bool status;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.cargo,
    this.phone,
    this.avatar,
    this.avatarBase64,
    this.roleName,
    this.partnerName,
    required this.status,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    String? roleName;
    if (json['role'] != null && json['role'] is Map) {
      roleName = json['role']['rol_name'] as String?;
    }

    // Fallback para par_legal_name é regra de negócio: parceiros
    String? partnerName;
    if (json['partner'] != null && json['partner'] is Map) {
      partnerName = (json['partner']['par_trade_name'] ??
          json['partner']['par_legal_name']) as String?;
    }

    return UserProfileModel(
      id: json['usr_userId'] as int,
      name: json['usr_name'] as String,
      email: json['usr_email'] as String,
      cargo: json['usr_cargo'] as String?,
      phone: json['usr_phone'] as String?,
      avatar: json['usr_avatar'] as String?,
      avatarBase64: json['usr_avatar_base64'] as String?,
      roleName: roleName,
      partnerName: partnerName,
      status: json['usr_status'] as bool,
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      name: name,
      email: email,
      cargo: cargo,
      phone: phone,
      avatar: avatar,
      avatarBase64: avatarBase64,
      roleName: roleName,
      partnerName: partnerName,
      status: status,
    );
  }

  static Map<String, dynamic> toUpdateMap({
    required String name,
    required String email,
    String? cargo,
    String? phone,
  }) {
    return {
      'usr_name': name,
      'usr_email': email,
      'usr_cargo': cargo,
      'usr_phone': phone,
    };
  }
}
