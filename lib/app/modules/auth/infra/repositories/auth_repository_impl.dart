import 'package:dartz/dartz.dart';
import '../../../../shared/core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userDto = await datasource.login(email: email, password: password);
      return Right(userDto.toEntity());
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await datasource.logout();
      return const Right(null);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final userDto = await datasource.getCurrentUser();
      return Right(userDto?.toEntity());
    } catch (error) {
      return Left(CacheFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isLoggedIn = await datasource.isLoggedIn();
      return Right(isLoggedIn);
    } catch (error) {
      return Left(CacheFailure(error.toString()));
    }
  }
}
