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
}
