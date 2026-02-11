import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class ResendOtpCodeUsecase {
  final AuthRepository repository;

  ResendOtpCodeUsecase(this.repository);

  
  Future<Either<Failure, void>> call({required String email}) async {

    if (email.isEmpty) {
      return const Left(ValidationFailure('Email é obrigatório'));
    }

    return repository.resendOtpCode(email: email);
  }
}
