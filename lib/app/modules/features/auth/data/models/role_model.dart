import 'package:copy_with_extension/copy_with_extension.dart';

import '../../domain/entities/role.dart';

part 'role_model.g.dart';

@CopyWith()
class RoleModel {
  final int id;
  final String name;
  final String description;
  final String? createdAt;
  final String? updatedAt;

  const RoleModel({
    required this.id,
    required this.name,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  /// Chaves conforme contrato do backend (`GET /api/perfil/me` → campo `role`)
  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['rol_roleId'] as int,
      name: json['rol_name'] as String,
      description: json['rol_description'] as String,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  /// Chaves alinhadas com a API para garantir round-trip do cache local
  Map<String, dynamic> toJson() {
    return {
      'rol_roleId': id,
      'rol_name': name,
      'rol_description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Role toEntity() {
    return Role(
      id: id,
      name: name,
      description: description,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    );
  }

  factory RoleModel.fromEntity(Role role) {
    return RoleModel(
      id: role.id,
      name: role.name,
      description: role.description,
      createdAt: role.createdAt?.toIso8601String(),
      updatedAt: role.updatedAt?.toIso8601String(),
    );
  }

  @override
  String toString() {
    return 'RoleModel(id: $id, name: $name, description: $description)';
  }
}
