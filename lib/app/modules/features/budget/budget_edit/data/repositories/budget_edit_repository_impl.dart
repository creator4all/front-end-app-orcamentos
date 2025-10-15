import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../../domain/entities/budget_edit_entity.dart';
import '../../domain/repositories/budget_edit_repository.dart';
import '../datasources/budget_edit_remote_datasource.dart';

class BudgetEditRepositoryImpl implements BudgetEditRepository {
  final BudgetEditRemoteDataSource remoteDataSource;

  BudgetEditRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<BudgetFailure, BudgetEditEntity>> getBudgetForEdit(
      int id) async {
    try {
      print('📦 [Repository] Buscando orçamento para edição: $id');

      final dto = await remoteDataSource.getBudgetForEdit(id);
      final entity = dto.toEntity();

      print('✅ [Repository] Orçamento convertido para entidade');

      return Right(entity);
    } on Exception catch (e) {
      print('❌ [Repository] Erro: $e');
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<BudgetFailure, BudgetEditEntity>> updateBudget({
    required int id,
    String? name,
    int? validityDays,
    DateTime? validityDate,
    String? status,
    bool? isArchived,
    List<int>? selectedProductIds,
  }) async {
    try {
      print('📦 [Repository] Atualizando orçamento: $id');

      final dto = await remoteDataSource.updateBudget(
        id: id,
        name: name,
        validityDays: validityDays,
        validityDate: validityDate,
        status: status,
        isArchived: isArchived,
        selectedProductIds: selectedProductIds,
      );

      final entity = dto.toEntity();

      print('✅ [Repository] Orçamento atualizado');

      return Right(entity);
    } on Exception catch (e) {
      print('❌ [Repository] Erro: $e');
      return Left(_mapExceptionToFailure(e));
    }
  }

  BudgetFailure _mapExceptionToFailure(Exception exception) {
    final message = exception.toString().replaceAll('Exception: ', '');

    if (message.contains('Timeout') || message.contains('timeout')) {
      return ServerFailure(message);
    }

    if (message.contains('não encontrado') || message.contains('404')) {
      return const NotFoundFailure('Orçamento não encontrado');
    }

    if (message.contains('Não autorizado') ||
        message.contains('401') ||
        message.contains('403')) {
      return const UnauthorizedFailure('Acesso negado');
    }

    if (message.contains('internet') || message.contains('conexão')) {
      return ConnectionFailure(message);
    }

    return UnknownFailure(message);
  }
}
