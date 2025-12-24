import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../../domain/entities/managed_user.dart';
import '../../domain/repositories/user_management_repository.dart';
import '../datasources/user_management_datasource.dart';
import '../models/user_update_dto.dart';

/// Implementação do repositório de gerenciamento de usuários
/// Converte dados do datasource em entidades de domínio e trata erros
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
      print('❌ [UserManagementRepositoryImpl] Erro ao listar usuários: $e');
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
      print('❌ [UserManagementRepositoryImpl] Erro ao atualizar usuários: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
