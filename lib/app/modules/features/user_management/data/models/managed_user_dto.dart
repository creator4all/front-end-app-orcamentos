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
  final String? avatarBase64;

  ManagedUserDto({
    required this.id,
    required this.name,
    required this.email,
    this.cargo,
    required this.status,
    required this.roleId,
    required this.roleName,
    this.avatarBase64,
  });

  /// Cria DTO a partir do JSON da API
  /// Suporta tanto formato limpo quanto formato Laravel Eloquent raw
  factory ManagedUserDto.fromJson(Map<String, dynamic> json) {
    // Debug: Log do JSON recebido
    print('🔍 [ManagedUserDto] JSON recebido keys: ${json.keys.toList()}');

    // Laravel Eloquent retorna dados dentro de '\u0000*\u0000attributes' ou 'attributes'
    // Precisamos extrair os dados de lá se existir
    Map<String, dynamic> attributes = json;
    Map<String, dynamic>? relations;

    // Procurar por chave 'attributes' (pode ter null bytes no prefixo)
    for (final key in json.keys) {
      if (key.contains('attributes')) {
        final attrValue = json[key];
        if (attrValue is Map<String, dynamic>) {
          attributes = attrValue;
          print('📋 [ManagedUserDto] Usando attributes: $attributes');
        }
      }
      if (key.contains('relations')) {
        final relValue = json[key];
        if (relValue is Map<String, dynamic>) {
          relations = relValue;
          print('📋 [ManagedUserDto] Usando relations: $relations');
        }
      }
    }

    // Extrair nome da role do objeto aninhado (relations ou diretamente)
    String roleName = 'Vendedor';
    int roleId =
        attributes['roles_rol_roleId'] ?? json['roles_rol_roleId'] ?? 1;

    // Verificar role em relations (Laravel Eloquent) ou diretamente no json
    final roleData = relations?['role'] ?? json['role'] ?? attributes['role'];
    if (roleData != null && roleData is Map) {
      roleName = roleData['rol_name'] ?? 'Vendedor';
      roleId = roleData['rol_roleId'] ?? roleId;
    }

    final dto = ManagedUserDto(
      id: attributes['usr_userId'] ?? json['usr_userId'] ?? 0,
      name: attributes['usr_name'] ?? json['usr_name'] ?? '',
      email: attributes['usr_email'] ?? json['usr_email'] ?? '',
      cargo: attributes['usr_cargo'] ?? json['usr_cargo'],
      status: (attributes['usr_status'] ?? json['usr_status']) == true ||
          (attributes['usr_status'] ?? json['usr_status']) == 1,
      roleId: roleId,
      roleName: roleName,
      avatarBase64: attributes['usr_avatar'] ?? json['usr_avatar'],
    );

    print(
        '✅ [ManagedUserDto] Parsed: id=${dto.id}, name=${dto.name}, email=${dto.email}, role=${dto.roleName}, status=${dto.status}');

    return dto;
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
      avatarBase64: avatarBase64,
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
    // Debug: Log do JSON completo
    print('🔍 [PaginatedUsersDto] JSON Response: $json');

    final dados = json['dados'] ?? json;
    print('🔍 [PaginatedUsersDto] dados: $dados');

    final List<dynamic> dataList = dados['data'] ?? [];
    print('🔍 [PaginatedUsersDto] dataList items: ${dataList.length}');

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
