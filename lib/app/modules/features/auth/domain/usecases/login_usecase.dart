import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../../../../../shared/utils/email_validator.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    

    if (email.isEmpty || password.isEmpty) {
      return const Left(ValidationFailure('Email e senha são obrigatórios'));
    }

    if (!EmailValidator.isValid(email)) {
      return const Left(ValidationFailure('Email inválido'));
    }

    if (password.length < 3) {
      return const Left(
          ValidationFailure('Senha deve ter pelo menos 3 caracteres'));
    }

    final result = await repository.login(email: email, password: password);

    result.fold(
      (failure) => Left(failure),
      (user) => Right(user),
    );

    return result;
  }
}
