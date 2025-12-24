import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/managed_user.dart';

/// Contrato abstrato do repositório de gerenciamento de usuários
/// Segue o princípio de inversão de dependência da Clean Architecture
abstract class UserManagementRepository {
  /// Lista usuários com paginação
  /// Retorna [Either] com [Failure] em caso de erro ou [PaginatedUsers] em caso de sucesso
  Future<Either<Failure, PaginatedUsers>> listUsers({
    required int page,
    required int perPage,
  });

  /// Atualiza múltiplos usuários em batch
  /// Retorna [Either] com [Failure] em caso de erro ou [UpdateUsersResult] em caso de sucesso
  Future<Either<Failure, UpdateUsersResult>> updateUsers(
    List<UserUpdate> updates,
  );
}
