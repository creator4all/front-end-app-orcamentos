import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/user_registration.dart';
import '../repositories/registration_repository.dart';

/// Use case para cadastrar novo usuário
class RegisterUserUseCase {
  final RegistrationRepository repository;

  RegisterUserUseCase(this.repository);

  /// Executa o cadastro de um novo usuário
  Future<Either<Failure, void>> call(UserRegistration registration) {
    return repository.registerUser(registration);
  }
}
