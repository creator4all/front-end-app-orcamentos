import 'package:copy_with_extension/copy_with_extension.dart';

import '../../domain/entities/user.dart';
import 'partner_model.dart';
import 'role_model.dart';

part 'user_model.g.dart';

@CopyWith()
class UserModel {
  final int id;
  final String name;
  final String email;
  final bool status;
  final bool delete;
  final String? avatar;
  final String? avatarBase64;
  final String? cargo;
  final String? phone;
  final String? deletedAt;
  final String? createdAt;
  final String? updatedAt;

  final PartnerModel? partner;
  final RoleModel? role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.delete,
    this.avatar,
    this.avatarBase64,
    this.cargo,
    this.phone,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.partner,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['usr_userId'] as int,
      name: json['usr_name'] as String,
      email: json['usr_email'] as String,
      status: json['usr_status'] as bool? ?? false,
      delete: json['usr_delete'] as bool? ?? false,
      avatar: json['usr_avatar'] as String?,
      avatarBase64: json['usr_avatar_base64'] as String?,
      cargo: json['usr_cargo'] as String?,
      phone: json['usr_phone'] as String?,
      deletedAt: json['usr_deleted_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      partner: json['partner'] != null
          ? PartnerModel.fromJson(json['partner'] as Map<String, dynamic>)
          : null,
      role: json['role'] != null
          ? RoleModel.fromJson(json['role'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usr_userId': id,
      'usr_name': name,
      'usr_email': email,
      'usr_status': status,
      'usr_delete': delete,
      'usr_avatar': avatar,
      'usr_avatar_base64': avatarBase64,
      'usr_cargo': cargo,
      'usr_phone': phone,
      'usr_deleted_at': deletedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'partner': partner?.toJson(),
      'role': role?.toJson(),
    };
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      status: status,
      delete: delete,
      avatar: avatar,
      avatarBase64: avatarBase64,
      cargo: cargo,
      phone: phone,
      deletedAt: deletedAt != null ? DateTime.tryParse(deletedAt!) : null,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
      partner: partner?.toEntity(),
      role: role?.toEntity(),
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      status: user.status,
      delete: user.delete,
      avatar: user.avatar,
      avatarBase64: user.avatarBase64,
      cargo: user.cargo,
      phone: user.phone,
      deletedAt: user.deletedAt?.toIso8601String(),
      createdAt: user.createdAt?.toIso8601String(),
      updatedAt: user.updatedAt?.toIso8601String(),
      partner:
          user.partner != null ? PartnerModel.fromEntity(user.partner!) : null,
      role: user.role != null ? RoleModel.fromEntity(user.role!) : null,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: ${role?.name}, partner: ${partner?.tradeName})';
  }
}
