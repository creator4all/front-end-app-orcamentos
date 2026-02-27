import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../../../../../shared/utils/email_validator.dart';
import '../repositories/auth_repository.dart';

class RequestPasswordResetUsecase {
  final AuthRepository repository;

  RequestPasswordResetUsecase(this.repository);

  Future<Either<Failure, void>> call({required String email}) async {

    if (email.isEmpty) {
      return const Left(ValidationFailure('Email é obrigatório'));
    }

    if (!EmailValidator.isValid(email)) {
      return const Left(ValidationFailure('Email inválido'));
    }

    return repository.requestPasswordReset(email: email);
  }
}
