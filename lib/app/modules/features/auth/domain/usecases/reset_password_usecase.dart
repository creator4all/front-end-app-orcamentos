import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para redefinir senha
/// Valida requisitos de senha antes de chamar a API
class ResetPasswordUsecase {
  final AuthRepository repository;

  ResetPasswordUsecase(this.repository);

  /// Redefine a senha do usuário
  /// Requisitos da senha:
  /// - Mínimo 6 caracteres
  /// - Pelo menos 1 letra maiúscula
  /// - Pelo menos 1 caractere especial
  /// Retorna Either<Failure, void>
  Future<Either<Failure, void>> call({
    required String email,
    required String otpCode,
    required String newPassword,
    required String confirmPassword,
  }) async {
    print('🔑 ResetPasswordUsecase.call() iniciado');
    print('   Email: $email');
    print('   OTP Code: $otpCode');

    // Validação de campos vazios
    if (email.isEmpty) {
      print('❌ Validação falhou: email vazio');
      return const Left(ValidationFailure('Email é obrigatório'));
    }

    if (otpCode.isEmpty) {
      print('❌ Validação falhou: código OTP vazio');
      return const Left(ValidationFailure('Código OTP é obrigatório'));
    }

    if (newPassword.isEmpty) {
      print('❌ Validação falhou: nova senha vazia');
      return const Left(ValidationFailure('Nova senha é obrigatória'));
    }

    if (confirmPassword.isEmpty) {
      print('❌ Validação falhou: confirmação de senha vazia');
      return const Left(
          ValidationFailure('Confirmação de senha é obrigatória'));
    }

    // Validação de senhas iguais
    if (newPassword != confirmPassword) {
      print('❌ Validação falhou: senhas não conferem');
      return const Left(ValidationFailure('As senhas não conferem'));
    }

    // Validação de requisitos de senha
    final passwordValidation = _validatePassword(newPassword);
    if (passwordValidation != null) {
      print('❌ Validação falhou: $passwordValidation');
      return Left(ValidationFailure(passwordValidation));
    }

    print('✅ Validações OK - Chamando repository.resetPassword()...');
    return repository.resetPassword(
      email: email,
      otpCode: otpCode,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  /// Valida os requisitos da senha
  /// Retorna null se válida, ou mensagem de erro se inválida
  String? _validatePassword(String password) {
    // Mínimo 6 caracteres
    if (password.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }

    // Pelo menos 1 letra maiúscula
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'A senha deve conter pelo menos 1 letra maiúscula';
    }

    // Pelo menos 1 caractere especial
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'A senha deve conter pelo menos 1 caractere especial';
    }

    return null; // Senha válida
  }

  /// Verifica se a senha atende aos requisitos (para uso externo)
  static bool isPasswordValid(String password) {
    if (password.length < 6) return false;
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) return false;
    return true;
  }

  /// Verifica requisito: mínimo 6 caracteres
  static bool hasMinLength(String password) => password.length >= 6;

  /// Verifica requisito: pelo menos 1 letra maiúscula
  static bool hasUppercase(String password) =>
      RegExp(r'[A-Z]').hasMatch(password);

  /// Verifica requisito: pelo menos 1 caractere especial
  static bool hasSpecialChar(String password) =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
}
