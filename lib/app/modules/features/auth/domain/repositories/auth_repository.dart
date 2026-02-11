import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, String?>> getStoredToken();

  Future<Either<Failure, bool>> validateToken();

  Future<Either<Failure, void>> requestPasswordReset({required String email});

  Future<Either<Failure, void>> resendOtpCode({required String email});

  Future<Either<Failure, bool>> verifyOtpCode({
    required String email,
    required String otpCode,
  });

  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
    required String confirmPassword,
  });

  Future<Either<Failure, User>> removeAvatar();
}
