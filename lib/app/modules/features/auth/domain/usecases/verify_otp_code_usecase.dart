import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpCodeUsecase {
  final AuthRepository repository;

  VerifyOtpCodeUsecase(this.repository);

  Future<Either<Failure, bool>> call({
    required String email,
    required String otpCode,
  }) async {
    if (email.isEmpty) {
      return const Left(ValidationFailure('Email é obrigatório'));
    }

    if (otpCode.isEmpty) {
      return const Left(ValidationFailure('Código OTP é obrigatório'));
    }

    if (otpCode.length != 6) {
      return const Left(ValidationFailure('Código deve ter 6 dígitos'));
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(otpCode)) {
      return const Left(ValidationFailure('Código deve conter apenas números'));
    }

    return repository.verifyOtpCode(email: email, otpCode: otpCode);
  }
}
