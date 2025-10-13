import 'package:copy_with_extension/copy_with_extension.dart';

import '../../domain/entities/user.dart';
import 'partner_model.dart';
import 'role_model.dart';

part 'user_model.g.dart';

/// Model de dados (DTO) para User
/// Responsável por serialização/deserialização JSON e conversão para Entity
@CopyWith()
class UserModel {
  final int id;
  final String name;
  final String email;
  final bool status;
  final bool delete;
  final String? avatar;
  final String? cargo;
  final String? phone;
  final String? deletedAt;
  final String? createdAt;
  final String? updatedAt;

  // ⭐ Objetos aninhados
  final PartnerModel? partner;
  final RoleModel? role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.delete,
    this.avatar,
    this.cargo,
    this.phone,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.partner,
    this.role,
  });

  /// Cria um UserModel a partir de JSON da API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('🔧 UserModel.fromJson - JSON recebido:');
    print('   Chaves disponíveis: ${json.keys.toList()}');

    final model = UserModel(
      id: json['usr_userId'] ?? json['id'] ?? 0,
      name: json['usr_name'] ?? json['name'] ?? '',
      email: json['usr_email'] ?? json['email'] ?? '',
      status: json['usr_status'] ?? json['status'] ?? false,
      delete: json['usr_delete'] ?? json['delete'] ?? false,
      avatar: json['usr_avatar'] ?? json['avatar'],
      cargo: json['usr_cargo'] ?? json['cargo'],
      phone: json['usr_phone'] ?? json['phone'],
      deletedAt:
          json['usr_deleted_at']?.toString() ?? json['deleted_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),

      // ⭐ PROCESSAR PARTNER ANINHADO
      partner: json['partner'] != null
          ? PartnerModel.fromJson(json['partner'] as Map<String, dynamic>)
          : null,

      // ⭐ PROCESSAR ROLE ANINHADO
      role: json['role'] != null
          ? RoleModel.fromJson(json['role'] as Map<String, dynamic>)
          : null,
    );

    print('✅ UserModel criado:');
    print('   ID=${model.id}, Nome=${model.name}');
    print('   Role=${model.role?.name ?? "N/A"}');
    print('   Partner=${model.partner?.tradeName ?? "N/A"}');

    return model;
  }

  /// Converte UserModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'status': status,
      'delete': delete,
      'avatar': avatar,
      'cargo': cargo,
      'phone': phone,
      'deleted_at': deletedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'partner': partner?.toJson(),
      'role': role?.toJson(),
    };
  }

  /// Converte UserModel para Entity (Domain)
  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      status: status,
      delete: delete,
      avatar: avatar,
      cargo: cargo,
      phone: phone,
      deletedAt: deletedAt != null ? DateTime.tryParse(deletedAt!) : null,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
      partner: partner?.toEntity(),
      role: role?.toEntity(),
    );
  }

  /// Cria UserModel a partir de Entity (Domain)
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      status: user.status,
      delete: user.delete,
      avatar: user.avatar,
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
