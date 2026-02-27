import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../../domain/entities/managed_user.dart';
import '../../domain/repositories/user_management_repository.dart';
import '../datasources/user_management_datasource.dart';
import '../models/user_update_dto.dart';

class UserManagementRepositoryImpl implements UserManagementRepository {
  final UserManagementDatasource datasource;

  UserManagementRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, PaginatedUsers>> listUsers({
    required int page,
    required int perPage,
  }) async {
    try {
      final result = await datasource.listUsers(page: page, perPage: perPage);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedUsers>> listPartnerUsers({
    required int partnerId,
    required int page,
    required int perPage,
  }) async {
    try {
      final result = await datasource.listPartnerUsers(
        partnerId: partnerId,
        page: page,
        perPage: perPage,
      );
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UpdateUsersResult>> updateUsers(
    List<UserUpdate> updates,
  ) async {
    try {
      final dtos = updates.map((e) => UserUpdateDto.fromEntity(e)).toList();
      final result = await datasource.updateUsers(dtos);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
