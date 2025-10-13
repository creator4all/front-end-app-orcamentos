import 'package:copy_with_extension/copy_with_extension.dart';

import '../../domain/entities/role.dart';

part 'role_model.g.dart';

/// Model de dados (DTO) para Role
/// Responsável por serialização/deserialização JSON e conversão para Entity
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

  /// Cria um RoleModel a partir de JSON da API
  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['rol_roleId'] ?? json['id'] ?? 0,
      name: json['rol_name'] ?? json['name'] ?? '',
      description: json['rol_description'] ?? json['description'] ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  /// Converte RoleModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Converte RoleModel para Entity (Domain)
  Role toEntity() {
    return Role(
      id: id,
      name: name,
      description: description,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    );
  }

  /// Cria RoleModel a partir de Entity (Domain)
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
