import 'package:equatable/equatable.dart';

/// Entidade de domínio que representa um usuário gerenciável
/// Esta é uma entidade pura sem dependências externas
class ManagedUser extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? cargo;
  final bool status;
  final int roleId;
  final String roleName;
  final String? avatarBase64;

  const ManagedUser({
    required this.id,
    required this.name,
    required this.email,
    this.cargo,
    required this.status,
    required this.roleId,
    required this.roleName,
    this.avatarBase64,
  });

  /// Cria uma cópia do usuário com valores alterados
  ManagedUser copyWith({
    int? id,
    String? name,
    String? email,
    String? cargo,
    bool? status,
    int? roleId,
    String? roleName,
    String? avatarBase64,
  }) {
    return ManagedUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      cargo: cargo ?? this.cargo,
      status: status ?? this.status,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      avatarBase64: avatarBase64 ?? this.avatarBase64,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        cargo,
        status,
        roleId,
        roleName,
        avatarBase64,
      ];

  @override
  bool get stringify => true;
}

/// Entidade que representa a resposta paginada de usuários
class PaginatedUsers extends Equatable {
  final List<ManagedUser> users;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  const PaginatedUsers({
    required this.users,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  bool get hasMore => currentPage < lastPage;

  @override
  List<Object?> get props => [users, currentPage, perPage, total, lastPage];
}

/// Entidade que representa uma atualização de usuário
class UserUpdate extends Equatable {
  final int userId;
  final bool? status;
  final int? roleId;

  const UserUpdate({
    required this.userId,
    this.status,
    this.roleId,
  });

  @override
  List<Object?> get props => [userId, status, roleId];
}

/// Entidade que representa o resultado da atualização
class UpdateUsersResult extends Equatable {
  final List<int> updated;
  final List<String> errors;
  final String message;

  const UpdateUsersResult({
    required this.updated,
    required this.errors,
    required this.message,
  });

  bool get isSuccess => errors.isEmpty;

  @override
  List<Object?> get props => [updated, errors, message];
}
