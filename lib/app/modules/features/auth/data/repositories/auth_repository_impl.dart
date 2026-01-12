import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

/// Implementação concreta do AuthRepository
/// Coordena o DataSource e converte Models em Entities
/// Trata exceções e retorna Either<Failure, Success>
class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    print('📚 AuthRepositoryImpl.login() iniciado');
    try {
      print('📞 Chamando datasource.login()...');
      final userModel = await datasource.login(
        email: email,
        password: password,
      );

      print('✅ Datasource retornou UserModel');
      // Converter Model para Entity
      final user = userModel.toEntity();
      print('✅ Model convertido para Entity');

      return Right(user);
    } catch (e) {
      print('❌ ERRO no AuthRepositoryImpl: $e');
      // Classificar o tipo de erro
      if (e.toString().contains('Credenciais inválidas') ||
          e.toString().contains('401')) {
        return const Left(AuthFailure('Email ou senha incorretos'));
      } else if (e.toString().contains('403') ||
          e.toString().contains('desativada')) {
        return const Left(
            AuthFailure('Conta desativada. Contate o administrador.'));
      } else if (e.toString().contains('internet') ||
          e.toString().contains('conexão') ||
          e.toString().contains('rede')) {
        return const Left(NetworkFailure(
            'Falha na conexão. Verifique sua internet e tente novamente.'));
      } else if (e.toString().contains('500') ||
          e.toString().contains('servidor')) {
        return const Left(
            ServerFailure('Erro no servidor. Tente novamente mais tarde.'));
      } else {
        return Left(ServerFailure('Erro ao fazer login: ${e.toString()}'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await datasource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao fazer logout: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userModel = await datasource.getCurrentUser();

      // Converter Model para Entity
      final user = userModel.toEntity();

      return Right(user);
    } catch (e) {
      if (e.toString().contains('Token não encontrado') ||
          e.toString().contains('Sessão expirada') ||
          e.toString().contains('401')) {
        return const Left(
            AuthFailure('Sessão expirada. Faça login novamente.'));
      } else if (e.toString().contains('internet') ||
          e.toString().contains('conexão')) {
        return const Left(NetworkFailure('Falha na conexão com o servidor'));
      } else {
        return Left(
            ServerFailure('Erro ao obter dados do usuário: ${e.toString()}'));
      }
    }
  }

  @override
  Future<Either<Failure, String?>> getStoredToken() async {
    try {
      final token = await datasource.getStoredToken();
      return Right(token);
    } catch (e) {
      return Left(CacheFailure('Erro ao acessar token: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> validateToken() async {
    try {
      final token = await datasource.getStoredToken();

      if (token == null) {
        return const Right(false);
      }

      final isValid = await datasource.validateToken(token);
      return Right(isValid);
    } catch (e) {
      if (e.toString().contains('internet') ||
          e.toString().contains('conexão')) {
        return const Left(NetworkFailure('Falha na conexão com o servidor'));
      } else {
        return Left(ServerFailure('Erro ao validar token: ${e.toString()}'));
      }
    }
  }

  // ===== Métodos para Recuperação de Senha =====

  @override
  Future<Either<Failure, void>> requestPasswordReset({
    required String email,
  }) async {
    try {
      await datasource.requestPasswordReset(email);
      return const Right(null);
    } catch (e) {
      // Tratar 403/usuário inativo com mensagem amigável
      if (e.toString().contains('403') || e.toString().contains('inativo')) {
        return const Left(AuthFailure(
            'Usuário inativo ou não encontrado. Em caso de dúvidas, entre em contato conosco pelo suporte.'));
      }
      if (e.toString().contains('não encontrado')) {
        return const Left(AuthFailure(
            'Usuário inativo ou não encontrado. Em caso de dúvidas, entre em contato conosco pelo suporte.'));
      } else if (e.toString().contains('internet') ||
          e.toString().contains('conexão')) {
        return const Left(NetworkFailure('Falha na conexão com o servidor'));
      } else if (e.toString().contains('servidor')) {
        return const Left(
            ServerFailure('Erro no servidor. Tente novamente mais tarde.'));
      } else {
        return const Left(AuthFailure(
            'Usuário inativo ou não encontrado. Em caso de dúvidas, entre em contato conosco pelo suporte.'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> resendOtpCode({required String email}) async {
    try {
      await datasource.resendOtpCode(email);
      return const Right(null);
    } catch (e) {
      if (e.toString().contains('Aguarde')) {
        return const Left(
            ValidationFailure('Aguarde antes de solicitar um novo código'));
      } else if (e.toString().contains('internet') ||
          e.toString().contains('conexão')) {
        return const Left(NetworkFailure('Falha na conexão com o servidor'));
      } else {
        return Left(ServerFailure('Erro ao reenviar código: ${e.toString()}'));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> verifyOtpCode({
    required String email,
    required String otpCode,
  }) async {
    try {
      final isValid = await datasource.verifyOtpCode(email, otpCode);
      return Right(isValid);
    } catch (e) {
      // Tratar todos os erros de verificação OTP com mensagem amigável
      if (e.toString().contains('internet') ||
          e.toString().contains('conexão')) {
        return const Left(NetworkFailure('Falha na conexão com o servidor'));
      } else {
        // Qualquer outro erro (inválido, expirado, não encontrado) mostra mensagem amigável
        return const Left(AuthFailure('Código OTP inválido ou expirado'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await datasource.resetPassword(
          email, otpCode, newPassword, confirmPassword);
      return const Right(null);
    } catch (e) {
      // Tratar erros de reset com mensagens amigáveis
      if (e.toString().contains('internet') ||
          e.toString().contains('conexão')) {
        return const Left(NetworkFailure('Falha na conexão com o servidor'));
      } else if (e.toString().contains('servidor') ||
          e.toString().contains('500')) {
        return const Left(
            ServerFailure('Erro no servidor. Tente novamente mais tarde.'));
      } else {
        // Qualquer outro erro mostra mensagem amigável
        return const Left(AuthFailure('Código OTP inválido ou expirado'));
      }
    }
  }
}
