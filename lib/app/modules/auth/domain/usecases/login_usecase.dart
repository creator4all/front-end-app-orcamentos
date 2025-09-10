import 'package:dartz/dartz.dart';
import '../../../../shared/core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return const Left(ValidationFailure('Email e senha são obrigatórios'));
    }

    if (!_isValidEmail(email)) {
      return const Left(ValidationFailure('Email inválido'));
    }

    return await repository.login(email: email, password: password);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
