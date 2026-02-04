import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../../../../../shared/utils/email_validator.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para solicitar recuperação de senha
/// Envia um código OTP para o email informado
class RequestPasswordResetUsecase {
  final AuthRepository repository;

  RequestPasswordResetUsecase(this.repository);

  /// Executa a solicitação de recuperação de senha
  /// Retorna Either<Failure, void>
  Future<Either<Failure, void>> call({required String email}) async {
    print('📧 RequestPasswordResetUsecase.call() iniciado');
    print('   Email: $email');

    // Validação de campo vazio
    if (email.isEmpty) {
      print('❌ Validação falhou: email vazio');
      return const Left(ValidationFailure('Email é obrigatório'));
    }

    // Validação de formato de email
    if (!EmailValidator.isValid(email)) {
      print('❌ Validação falhou: email inválido');
      return const Left(ValidationFailure('Email inválido'));
    }

    print('✅ Validações OK - Chamando repository.requestPasswordReset()...');
    return repository.requestPasswordReset(email: email);
  }
}
