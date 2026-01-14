import '../models/managed_user_dto.dart';
import '../models/user_update_dto.dart';

/// Interface abstrata para datasource de gerenciamento de usuários
abstract class UserManagementDatasource {
  /// Lista usuários com paginação
  /// GET /api/parceiro/usuarios (para Gestor)
  Future<PaginatedUsersDto> listUsers({
    required int page,
    required int perPage,
  });

  /// Lista usuários de um parceiro específico
  /// GET /api/partners/{partnerId}/usuarios (para Admin)
  Future<PaginatedUsersDto> listPartnerUsers({
    required int partnerId,
    required int page,
    required int perPage,
  });

  /// Atualiza status e/ou role de múltiplos usuários
  Future<UpdateUsersResponseDto> updateUsers(List<UserUpdateDto> updates);
}
