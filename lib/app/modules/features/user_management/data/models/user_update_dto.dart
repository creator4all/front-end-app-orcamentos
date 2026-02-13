import '../../domain/entities/managed_user.dart';

class UserUpdateDto {
  final int userId;
  final bool? status;
  final int? roleId;

  UserUpdateDto({
    required this.userId,
    this.status,
    this.roleId,
  });

  factory UserUpdateDto.fromEntity(UserUpdate entity) {
    return UserUpdateDto(
      userId: entity.userId,
      status: entity.status,
      roleId: entity.roleId,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'usr_userId': userId,
    };

    if (status != null) {
      json['usr_status'] = status;
    }

    if (roleId != null) {
      json['roles_rol_roleId'] = roleId;
    }

    return json;
  }
}

class UpdateUsersResponseDto {
  final List<int> updated;
  final List<String> errors;
  final String message;

  UpdateUsersResponseDto({
    required this.updated,
    required this.errors,
    required this.message,
  });

  factory UpdateUsersResponseDto.fromJson(Map<String, dynamic> json) {
    final dados = json['dados'] as Map<String, dynamic>;

    final atualizadosList = dados['atualizados'] ?? [];
    final List<int> updated = (atualizadosList as List)
        .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
        .toList();

    final errosList = dados['erros'] ?? [];
    final List<String> errors =
        (errosList as List).map((e) => e.toString()).toList();

    return UpdateUsersResponseDto(
      updated: updated,
      errors: errors,
      message: dados['mensagem'] ?? 'Atualização concluída',
    );
  }

  UpdateUsersResult toEntity() {
    return UpdateUsersResult(
      updated: updated,
      errors: errors,
      message: message,
    );
  }
}
