import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso responsável por obter os dados do usuário logado
/// Busca no cache local ou valida com a API
class GetCurrentUserUsecase {
  final AuthRepository repository;

  GetCurrentUserUsecase(this.repository);

  /// Obtém o usuário atual
  /// Retorna Either<Failure, User>
  Future<Either<Failure, User>> call() async {
    return await repository.getCurrentUser();
  }
}
