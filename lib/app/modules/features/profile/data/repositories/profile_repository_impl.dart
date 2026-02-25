import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/app_error.dart';
import '../../../../../shared/core/errors/failures.dart';
import '../../../../../shared/core/errors/http_exceptions.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDatasource datasource;

  ProfileRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    try {
      final model = await datasource.getProfile();
      return Right(model.toEntity());
    } on AppInternetError catch (e) {
      return Left(NetworkFailure(e.message));
    } on AppError catch (e) {
      return Left(ServerFailure(e.message));
    } on ConnectionException {
      return const Left(NetworkFailure('Falha na conexão com o servidor'));
    } on TimeoutException {
      return const Left(NetworkFailure('Tempo de conexão esgotado'));
    } on HttpException catch (e) {
      return Left(ServerFailure('Erro ${e.statusCode}: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro ao carregar perfil: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile(
      Map<String, dynamic> data) async {
    try {
      final model = await datasource.updateProfile(data);
      return Right(model.toEntity());
    } on AppInternetError catch (e) {
      return Left(NetworkFailure(e.message));
    } on AppError catch (e) {
      return Left(ServerFailure(e.message));
    } on ConnectionException {
      return const Left(NetworkFailure('Falha na conexão com o servidor'));
    } on TimeoutException {
      return const Left(NetworkFailure('Tempo de conexão esgotado'));
    } on HttpException catch (e) {
      return Left(ServerFailure('Erro ${e.statusCode}: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar perfil: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> deleteAccount() async {
    try {
      final message = await datasource.deleteAccount();
      return Right(message);
    } on AppInternetError catch (e) {
      return Left(NetworkFailure(e.message));
    } on AppError catch (e) {
      return Left(ServerFailure(e.message));
    } on ConnectionException {
      return const Left(NetworkFailure('Falha na conexão com o servidor'));
    } on TimeoutException {
      return const Left(NetworkFailure('Tempo de conexão esgotado'));
    } on HttpException catch (e) {
      return Left(ServerFailure('Erro ${e.statusCode}: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro ao excluir conta: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> uploadAvatar(File imageFile) async {
    try {
      final model = await datasource.uploadAvatar(imageFile);
      return Right(model.toEntity());
    } on AppInternetError catch (e) {
      return Left(NetworkFailure(e.message));
    } on AppError catch (e) {
      return Left(ServerFailure(e.message));
    } on ConnectionException {
      return const Left(NetworkFailure('Falha na conexão com o servidor'));
    } on TimeoutException {
      return const Left(NetworkFailure('Tempo de conexão esgotado'));
    } on HttpException catch (e) {
      return Left(ServerFailure('Erro ${e.statusCode}: ${e.message}'));
    } catch (e) {
      return Left(
          ServerFailure('Erro ao fazer upload do avatar: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> removeAvatar() async {
    try {
      final model = await datasource.removeAvatar();
      return Right(model.toEntity());
    } on AppInternetError catch (e) {
      return Left(NetworkFailure(e.message));
    } on AppError catch (e) {
      return Left(ServerFailure(e.message));
    } on ConnectionException {
      return const Left(NetworkFailure('Falha na conexão com o servidor'));
    } on TimeoutException {
      return const Left(NetworkFailure('Tempo de conexão esgotado'));
    } on HttpException catch (e) {
      return Left(ServerFailure('Erro ${e.statusCode}: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro ao remover avatar: ${e.toString()}'));
    }
  }
}
