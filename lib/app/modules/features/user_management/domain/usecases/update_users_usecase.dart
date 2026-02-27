import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/managed_user.dart';
import '../repositories/user_management_repository.dart';

/// UseCase para atualizar múltiplos usuários em batch
/// Segue o princípio de responsabilidade única
class UpdateUsersUsecase {
  final UserManagementRepository repository;

  UpdateUsersUsecase(this.repository);

  /// Executa o caso de uso de atualização de usuários
  Future<Either<Failure, UpdateUsersResult>> call(
    List<UserUpdate> updates,
  ) async {
    if (updates.isEmpty) {
      return const Right(UpdateUsersResult(
        updated: [],
        errors: [],
        message: 'Nenhuma alteração para salvar',
      ));
    }
    return repository.updateUsers(updates);
  }
}
