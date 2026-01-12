import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/user.dart';

/// Contrato abstrato do repositório de autenticação
/// Define as operações que podem ser realizadas sem especificar a implementação
abstract class AuthRepository {
  /// Realiza o login do usuário com email e senha
  /// Retorna Either<Failure, User> onde:
  /// - Left: Erro (Failure)
  /// - Right: Sucesso (User)
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Realiza o logout do usuário
  /// Remove o token e limpa os dados armazenados
  Future<Either<Failure, void>> logout();

  /// Obtém o usuário atualmente logado
  /// Busca no cache local ou valida o token com a API
  Future<Either<Failure, User>> getCurrentUser();

  /// Verifica se existe um token válido armazenado
  Future<Either<Failure, String?>> getStoredToken();

  /// Valida se o token atual ainda é válido
  Future<Either<Failure, bool>> validateToken();

  // ===== Métodos para Recuperação de Senha =====

  /// Solicita recuperação de senha enviando OTP para o email
  /// POST /api/auth/forgot-password
  Future<Either<Failure, void>> requestPasswordReset({required String email});

  /// Reenvia código OTP para o email (após 1 minuto)
  /// POST /api/auth/forgot-password/resend
  Future<Either<Failure, void>> resendOtpCode({required String email});

  /// Verifica se o código OTP é válido
  /// POST /api/auth/forgot-password/validate-otp
  Future<Either<Failure, bool>> verifyOtpCode({
    required String email,
    required String otpCode,
  });

  /// Redefine a senha do usuário
  /// POST /api/auth/reset-password
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
    required String confirmPassword,
  });
}
