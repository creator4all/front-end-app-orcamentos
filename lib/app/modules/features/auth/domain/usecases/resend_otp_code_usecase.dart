import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para reenviar código OTP
/// Deve ser chamado somente após 1 minuto do último envio
class ResendOtpCodeUsecase {
  final AuthRepository repository;

  ResendOtpCodeUsecase(this.repository);

  /// Reenvia o código OTP para o email
  /// Retorna Either<Failure, void>
  Future<Either<Failure, void>> call({required String email}) async {
    print('🔄 ResendOtpCodeUsecase.call() iniciado');
    print('   Email: $email');

    // Validação de campo vazio
    if (email.isEmpty) {
      print('❌ Validação falhou: email vazio');
      return const Left(ValidationFailure('Email é obrigatório'));
    }

    print('✅ Validações OK - Chamando repository.resendOtpCode()...');
    return repository.resendOtpCode(email: email);
  }
}
