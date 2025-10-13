import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso responsável por realizar o logout do usuário
/// Remove o token e limpa os dados armazenados
class LogoutUsecase {
  final AuthRepository repository;

  LogoutUsecase(this.repository);

  /// Executa o logout
  /// Retorna Either<Failure, void>
  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}
