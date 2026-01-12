import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para verificar código OTP
/// Valida se o código de 6 dígitos está correto
class VerifyOtpCodeUsecase {
  final AuthRepository repository;

  VerifyOtpCodeUsecase(this.repository);

  /// Verifica se o código OTP é válido
  /// Retorna Either<Failure, bool>
  Future<Either<Failure, bool>> call({
    required String email,
    required String otpCode,
  }) async {
    print('🔢 VerifyOtpCodeUsecase.call() iniciado');
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

    // Validação de formato do código OTP (6 dígitos numéricos)
    if (otpCode.length != 6) {
      print('❌ Validação falhou: código deve ter 6 dígitos');
      return const Left(ValidationFailure('Código deve ter 6 dígitos'));
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(otpCode)) {
      print('❌ Validação falhou: código deve conter apenas números');
      return const Left(ValidationFailure('Código deve conter apenas números'));
    }

    print('✅ Validações OK - Chamando repository.verifyOtpCode()...');
    return repository.verifyOtpCode(email: email, otpCode: otpCode);
  }
}
