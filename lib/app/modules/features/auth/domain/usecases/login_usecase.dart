import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso responsável por realizar o login do usuário
/// Valida as credenciais antes de chamar o repositório
class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  /// Executa o login com validações
  /// Retorna Either<Failure, User>
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    print('🔐 LoginUsecase.call() iniciado');
    print('   Email: $email');

    // Validação de campos vazios
    if (email.isEmpty || password.isEmpty) {
      print('❌ Validação falhou: campos vazios');
      return const Left(ValidationFailure('Email e senha são obrigatórios'));
    }

    // Validação de formato de email
    if (!_isValidEmail(email)) {
      print('❌ Validação falhou: email inválido');
      return const Left(ValidationFailure('Email inválido'));
    }

    // Validação de senha mínima
    if (password.length < 3) {
      print('❌ Validação falhou: senha muito curta');
      return const Left(
          ValidationFailure('Senha deve ter pelo menos 3 caracteres'));
    }

    print('✅ Validações OK - Chamando repository.login()...');
    // Chama o repositório para realizar o login
    final result = await repository.login(email: email, password: password);

    result.fold(
      (failure) => print('❌ Repository retornou FAILURE: ${failure.message}'),
      (user) => print('✅ Repository retornou SUCCESS: User ID=${user.id}'),
    );

    return result;
  }

  /// Valida o formato do email usando RegExp
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
