import 'package:equatable/equatable.dart';

import 'partner.dart';
import 'role.dart';

/// Entidade de domínio que representa um usuário do sistema
/// Esta é uma entidade pura sem dependências externas
class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final bool status;
  final bool delete;
  final String? avatar;
  final String? cargo;
  final String? phone;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ⭐ Objetos aninhados completos
  final Partner? partner;
  final Role? role;

  const User({
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

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        status,
        delete,
        avatar,
        cargo,
        phone,
        deletedAt,
        createdAt,
        updatedAt,
        partner,
        role,
      ];

  @override
  bool get stringify => true;
}
