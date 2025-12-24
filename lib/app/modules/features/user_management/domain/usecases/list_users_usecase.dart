import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/managed_user.dart';
import '../repositories/user_management_repository.dart';

/// UseCase para listar usuários com paginação
/// Segue o princípio de responsabilidade única
class ListUsersUsecase {
  final UserManagementRepository repository;

  ListUsersUsecase(this.repository);

  /// Executa o caso de uso de listagem de usuários
  Future<Either<Failure, PaginatedUsers>> call({
    required int page,
    int perPage = 15,
  }) async {
    return repository.listUsers(page: page, perPage: perPage);
  }
}
