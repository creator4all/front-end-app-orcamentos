import '../../domain/entities/managed_user.dart';

/// DTO para parsing do JSON de usuário da API
class ManagedUserDto {
  final int id;
  final String name;
  final String email;
  final String? cargo;
  final bool status;
  final int roleId;
  final String roleName;

  ManagedUserDto({
    required this.id,
    required this.name,
    required this.email,
    this.cargo,
    required this.status,
    required this.roleId,
    required this.roleName,
  });

  /// Cria DTO a partir do JSON da API
  factory ManagedUserDto.fromJson(Map<String, dynamic> json) {
    // Extrair nome da role do objeto aninhado
    String roleName = 'Vendedor';
    int roleId = json['roles_rol_roleId'] ?? 1;

    if (json['role'] != null && json['role'] is Map) {
      roleName = json['role']['rol_name'] ?? 'Vendedor';
      roleId = json['role']['rol_roleId'] ?? roleId;
    }

    return ManagedUserDto(
      id: json['usr_userId'] ?? 0,
      name: json['usr_name'] ?? '',
      email: json['usr_email'] ?? '',
      cargo: json['usr_cargo'],
      status: json['usr_status'] == true || json['usr_status'] == 1,
      roleId: roleId,
      roleName: roleName,
    );
  }

  /// Converte DTO para entidade de domínio
  ManagedUser toEntity() {
    return ManagedUser(
      id: id,
      name: name,
      email: email,
      cargo: cargo,
      status: status,
      roleId: roleId,
      roleName: roleName,
    );
  }
}

/// DTO para parsing da resposta paginada da API
class PaginatedUsersDto {
  final List<ManagedUserDto> users;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  PaginatedUsersDto({
    required this.users,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  /// Cria DTO a partir do JSON da API
  factory PaginatedUsersDto.fromJson(Map<String, dynamic> json) {
    final dados = json['dados'] ?? json;
    final List<dynamic> dataList = dados['data'] ?? [];
    final pagination = dados['pagination'] ?? {};

    return PaginatedUsersDto(
      users: dataList.map((e) => ManagedUserDto.fromJson(e)).toList(),
      currentPage: pagination['current_page'] ?? 1,
      perPage: pagination['per_page'] ?? 15,
      total: pagination['total'] ?? 0,
      lastPage: pagination['last_page'] ?? 1,
    );
  }

  /// Converte DTO para entidade de domínio
  PaginatedUsers toEntity() {
    return PaginatedUsers(
      users: users.map((dto) => dto.toEntity()).toList(),
      currentPage: currentPage,
      perPage: perPage,
      total: total,
      lastPage: lastPage,
    );
  }
}
