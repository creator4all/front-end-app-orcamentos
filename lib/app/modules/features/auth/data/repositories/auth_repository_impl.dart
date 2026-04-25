import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../../../../../shared/core/errors/http_exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await datasource.login(
        email: email,
        password: password,
      );

      final user = userModel.toEntity();

      return Right(user);
    } on UnauthorizedException {
      return const Left(AuthFailure('Email ou senha incorretos'));
    } on ForbiddenException {
      return const Left(
          AuthFailure('Conta desativada. Contate o administrador.'));
    } on ConnectionException {
      return const Left(NetworkFailure(
          'Falha na conexão. Verifique sua internet e tente novamente.'));
    } on TimeoutException {
      return const Left(
          NetworkFailure('Tempo de conexão esgotado. Tente novamente.'));
    } on InternalServerException {
      return const Left(
          ServerFailure('Erro no servidor. Tente novamente mais tarde.'));
    } on HttpException catch (e) {
      return Left(ServerFailure('Erro ${e.statusCode}: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro ao fazer login: ${e.toString()}'));
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
  Future<Either<Failure, User>> getCurrentUser({bool forceRefresh = false}) async {
    try {
      final userModel = await datasource.getCurrentUser(forceRefresh: forceRefresh);

      final user = userModel.toEntity();

      return Right(user);
    } on UnauthorizedException {
      return const Left(AuthFailure('Sessão expirada. Faça login novamente.'));
    } on ConnectionException {
      return const Left(NetworkFailure('Falha na conexão com o servidor'));
    } on TimeoutException {
      return const Left(NetworkFailure('Tempo de conexão esgotado'));
    } on HttpException catch (e) {
      return Left(ServerFailure('Erro ${e.statusCode}: ${e.message}'));
    } catch (e) {
      return Left(
          ServerFailure('Erro ao obter dados do usuário: ${e.toString()}'));
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
    } on ConnectionException {
      return const Left(NetworkFailure('Falha na conexão com o servidor'));
    } on TimeoutException {
      return const Left(NetworkFailure('Tempo de conexão esgotado'));
    } on HttpException catch (e) {
      return Left(ServerFailure('Erro ${e.statusCode}: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro ao validar token: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> requestPasswordReset({
    required String email,
  }) async {
    try {
      await datasource.requestPasswordReset(email);
      return const Right(null);
    } on ForbiddenException {
      return const Left(AuthFailure(
          'Usuário inativo ou não encontrado. Em caso de dúvidas, entre em contato conosco pelo suporte.'));
    } on NotFoundException {
      return const Left(AuthFailure(
          'Usuário inativo ou não encontrado. Em caso de dúvidas, entre em contato conosco pelo suporte.'));
    } on ConnectionException {
      return const Left(NetworkFailure('Falha na conexão com o servidor'));
    } on TimeoutException {
      return const Left(NetworkFailure('Tempo de conexão esgotado'));
    } on InternalServerException {
      return const Left(
          ServerFailure('Erro no servidor. Tente novamente mais tarde.'));
    } on HttpException catch (e) {
      return Left(ServerFailure('Erro ${e.statusCode}: ${e.message}'));
    } catch (e) {
      return const Left(AuthFailure(
          'Usuário inativo ou não encontrado. Em caso de dúvidas, entre em contato conosco pelo suporte.'));
    }
  }

  @override
  Future<Either<Failure, void>> resendOtpCode({required String email}) async {
    try {
      await datasource.resendOtpCode(email);
      return const Right(null);
    } on TooManyRequestsException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ConnectionException {
      return const Left(NetworkFailure('Falha na conexão com o servidor'));
    } on TimeoutException {
      return const Left(NetworkFailure('Tempo de conexão esgotado'));
    } on HttpException catch (e) {
      return Left(ServerFailure('Erro ${e.statusCode}: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro ao reenviar código: ${e.toString()}'));
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
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on BadRequestException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(AuthFailure(e.message));
    } on ConnectionException {
      return const Left(NetworkFailure('Falha na conexão com o servidor'));
    } on TimeoutException {
      return const Left(NetworkFailure('Tempo de conexão esgotado'));
    } on HttpException catch (e) {
      return Left(ServerFailure('Erro ${e.statusCode}: ${e.message}'));
    } catch (e) {
      return const Left(ServerFailure('Erro ao verificar código. Tente novamente.'));
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
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on BadRequestException catch (e) {
      return Left(AuthFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(AuthFailure(e.message));
    } on ConnectionException {
      return const Left(NetworkFailure('Falha na conexão com o servidor'));
    } on TimeoutException {
      return const Left(NetworkFailure('Tempo de conexão esgotado'));
    } on InternalServerException {
      return const Left(
          ServerFailure('Erro no servidor. Tente novamente mais tarde.'));
    } on HttpException catch (e) {
      return Left(ServerFailure('Erro ${e.statusCode}: ${e.message}'));
    } catch (e) {
      return const Left(ServerFailure('Erro ao redefinir senha. Tente novamente.'));
    }
  }

  @override
  Future<Either<Failure, User>> removeAvatar() async {
    try {
      final userModel = await datasource.removeAvatar();
      return Right(userModel.toEntity());
    } on ConnectionException {
      return const Left(NetworkFailure('Falha na conexão com o servidor'));
    } on TimeoutException {
      return const Left(NetworkFailure('Tempo de conexão esgotado'));
    } on HttpException catch (e) {
      return Left(ServerFailure('Erro ${e.statusCode}: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
