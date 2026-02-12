import '../../domain/entities/managed_user.dart';

/// DTO para payload de atualização de usuário
class UserUpdateDto {
  final int userId;
  final bool? status;
  final int? roleId;

  UserUpdateDto({
    required this.userId,
    this.status,
    this.roleId,
  });

  /// Cria DTO a partir da entidade de domínio
  factory UserUpdateDto.fromEntity(UserUpdate entity) {
    return UserUpdateDto(
      userId: entity.userId,
      status: entity.status,
      roleId: entity.roleId,
    );
  }

  /// Converte DTO para JSON para envio à API
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

/// DTO para resposta de atualização de usuários
class UpdateUsersResponseDto {
  final List<int> updated;
  final List<String> errors;
  final String message;

  UpdateUsersResponseDto({
    required this.updated,
    required this.errors,
    required this.message,
  });

  /// Cria DTO a partir do JSON da API
  factory UpdateUsersResponseDto.fromJson(Map<String, dynamic> json) {
    final dados = json['dados'] as Map<String, dynamic>;

    // Garantir que atualizados seja uma lista de int
    final atualizadosList = dados['atualizados'] ?? [];
    final List<int> updated = (atualizadosList as List)
        .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
        .toList();

    // Garantir que erros seja uma lista de String
    final errosList = dados['erros'] ?? [];
    final List<String> errors =
        (errosList as List).map((e) => e.toString()).toList();

    return UpdateUsersResponseDto(
      updated: updated,
      errors: errors,
      message: dados['mensagem'] ?? 'Atualização concluída',
    );
  }

  /// Converte DTO para entidade de domínio
  UpdateUsersResult toEntity() {
    return UpdateUsersResult(
      updated: updated,
      errors: errors,
      message: message,
    );
  }
}
