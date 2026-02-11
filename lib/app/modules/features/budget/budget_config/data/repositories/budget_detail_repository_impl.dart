import 'package:dartz/dartz.dart';

import '../../../../../../shared/core/constants/http_constants.dart';
import '../../../shared/errors/budget_failure.dart';
import '../../../shared/models/budget_update_dto.dart';
import '../../domain/entities/budget_detail_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/budget_detail_repository.dart';
import '../datasources/budget_detail_remote_datasource.dart';

/// Implementação concreta do BudgetDetailRepository
class BudgetDetailRepositoryImpl implements BudgetDetailRepository {
  final BudgetDetailRemoteDataSource remoteDataSource;

  BudgetDetailRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<BudgetFailure, BudgetDetailEntity>> getBudgetById(
      int id) async {
    try {
      final dto = await remoteDataSource.getBudgetById(id);
      final entity = dto.toEntity();

      return Right(entity);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<BudgetFailure, List<ProductEntity>>> getAllProducts({
    required int budgetId,
  }) async {
    try {
      final dtos = await remoteDataSource.getAllProducts(
        budgetId: budgetId,
      );

      // Converter DTOs para Entities
      final entities = dtos.map((dto) => dto.toEntity()).toList();

      return Right(entities);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<BudgetFailure, List<ProductEntity>>> getCategoryProducts({
    required int budgetId,
    required int categoryId,
  }) async {
    try {
      final dtos = await remoteDataSource.getCategoryProducts(
        budgetId: budgetId,
        categoryId: categoryId,
      );

      // Converter DTOs para Entities
      final entities = dtos.map((dto) => dto.toEntity()).toList();

      return Right(entities);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<BudgetFailure, BudgetDetailEntity>> updateBudget({
    required int id,
    String? name,
    String? status,
    DateTime? validityDate,
    Map<String, bool>? categoryStates,
    List<int>? selectedProductIds,
  }) async {
    try {
      print('📦 [Repository] Atualizando orçamento ID: $id');

      final dto = await remoteDataSource.updateBudget(
        id: id,
        name: name,
        status: status,
        validityDate: validityDate,
        categoryStates: categoryStates,
        selectedProductIds: selectedProductIds,
      );

      final entity = dto.toEntity();

      print('✅ [Repository] Orçamento atualizado e convertido');

      return Right(entity);
    } on Exception catch (e) {
      print('❌ [Repository] Erro: $e');
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<BudgetFailure, BudgetDetailEntity>> updateBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  }) async {
    try {
      print('📦 [Repository] Atualizando orçamento ID: $budgetId com DTO');
      print('   📝 Dados: ${updateData.toString()}');

      final dto = await remoteDataSource.updateBudgetWithDto(
        budgetId: budgetId,
        updateData: updateData,
      );

      final entity = dto.toEntity();

      print('✅ [Repository] Orçamento atualizado com sucesso via DTO');

      return Right(entity);
    } on Exception catch (e) {
      print('❌ [Repository] Erro ao atualizar com DTO: $e');
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Mapeia exceções para failures
  BudgetFailure _mapExceptionToFailure(Exception exception) {
    final message = exception.toString().replaceAll('Exception: ', '');

    if (message.contains('Timeout') || message.contains('timeout')) {
      return ServerFailure(message);
    }

    if (message.contains('não encontrado') ||
        message.contains('${HttpStatusCodes.notFound}')) {
      return const NotFoundFailure('Orçamento não encontrado');
    }

    if (message.contains('Não autorizado') ||
        message.contains('${HttpStatusCodes.unauthorized}') ||
        message.contains('${HttpStatusCodes.forbidden}')) {
      return const UnauthorizedFailure('Acesso negado');
    }

    if (message.contains('internet') || message.contains('conexão')) {
      return ConnectionFailure(message);
    }

    return UnknownFailure(message);
  }
}
