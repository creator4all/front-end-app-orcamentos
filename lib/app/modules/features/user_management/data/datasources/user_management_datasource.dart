import '../models/managed_user_dto.dart';
import '../models/user_update_dto.dart';

/// Interface abstrata do datasource de gerenciamento de usuários
abstract class UserManagementDatasource {
  /// Lista usuários com paginação
  Future<PaginatedUsersDto> listUsers({
    required int page,
    required int perPage,
  });

  /// Atualiza múltiplos usuários em batch
  Future<UpdateUsersResponseDto> updateUsers(List<UserUpdateDto> updates);
}
