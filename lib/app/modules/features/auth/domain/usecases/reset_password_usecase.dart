import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUsecase {
  final AuthRepository repository;

  ResetPasswordUsecase(this.repository);

  Future<Either<Failure, void>> call({
    required String email,
    required String otpCode,
    required String newPassword,
    required String confirmPassword,
  }) async {

    if (email.isEmpty) {
      return const Left(ValidationFailure('Email é obrigatório'));
    }

    if (otpCode.isEmpty) {
      return const Left(ValidationFailure('Código OTP é obrigatório'));
    }

    if (newPassword.isEmpty) {
      return const Left(ValidationFailure('Nova senha é obrigatória'));
    }

    if (confirmPassword.isEmpty) {
      return const Left(
          ValidationFailure('Confirmação de senha é obrigatória'));
    }
    if (newPassword != confirmPassword) {
      return const Left(ValidationFailure('As senhas não conferem'));
    }

    final passwordValidation = _validatePassword(newPassword);
    if (passwordValidation != null) {
      return Left(ValidationFailure(passwordValidation));
    }
    return repository.resetPassword(
      email: email,
      otpCode: otpCode,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  String? _validatePassword(String password) {
    if (password.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'A senha deve conter pelo menos 1 letra maiúscula';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'A senha deve conter pelo menos 1 caractere especial';
    }

    return null;
  }

  static bool isPasswordValid(String password) {
    if (password.length < 6) return false;
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) return false;
    return true;
  }

  static bool hasMinLength(String password) => password.length >= 6;

  static bool hasUppercase(String password) =>
      RegExp(r'[A-Z]').hasMatch(password);
  static bool hasSpecialChar(String password) =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
}
