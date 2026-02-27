import 'package:dartz/dartz.dart';

import '../../../../../../shared/core/constants/http_constants.dart';
import '../../../../../../shared/core/errors/http_exceptions.dart'
    as core_http;
import '../../../shared/errors/budget_failure.dart';
import '../../../shared/models/budget_update_dto.dart';
import '../../domain/entities/budget_detail_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/budget_detail_repository.dart';
import '../datasources/budget_detail_remote_datasource.dart';

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
  Future<Either<BudgetFailure, List<ProductEntity>>> getCategoryProducts({
    required int budgetId,
    required int categoryId,
  }) async {
    try {
      final dtos = await remoteDataSource.getCategoryProducts(
        budgetId: budgetId,
        categoryId: categoryId,
      );

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

      final dto = await remoteDataSource.updateBudget(
        id: id,
        name: name,
        status: status,
        validityDate: validityDate,
        categoryStates: categoryStates,
        selectedProductIds: selectedProductIds,
      );

      final entity = dto.toEntity();

      return Right(entity);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<BudgetFailure, BudgetDetailEntity>> updateBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  }) async {
    try {
      final dto = await remoteDataSource.updateBudgetWithDto(
        budgetId: budgetId,
        updateData: updateData,
      );

      final entity = dto.toEntity();

      return Right(entity);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  BudgetFailure _mapExceptionToFailure(Exception exception) {
    if (exception is core_http.UnprocessableEntityException) {
      final message = _extractValidationMessage(
        exception.validationErrors,
        exception.message,
      );
      return ValidationFailure(message);
    }

    if (exception is core_http.HttpException) {
      final statusCode = exception.statusCode;

      if (statusCode == HttpStatusCodes.unprocessableEntity) {
        final payload =
            exception.data is Map<String, dynamic> ? exception.data : null;
        final message = _extractValidationMessage(payload, exception.message);
        return ValidationFailure(message);
      }

      if (statusCode == HttpStatusCodes.notFound) {
        return const NotFoundFailure('Orçamento não encontrado');
      }

      if (statusCode == HttpStatusCodes.unauthorized ||
          statusCode == HttpStatusCodes.forbidden) {
        return const UnauthorizedFailure('Acesso negado');
      }

      if (statusCode != null && statusCode >= 500) {
        return ServerFailure(exception.message);
      }
    }

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

  String _extractValidationMessage(
    Map<String, dynamic>? payload,
    String fallback,
  ) {
    if (payload == null) return fallback;

    final directValidityError = _extractFirstString(
      payload['orc_dias_validade'] ?? payload['dias_validade'],
    );
    if (directValidityError != null) {
      return directValidityError;
    }

    final errors =
        payload['errors'] ?? payload['erros'] ?? payload['dados'] ?? payload;

    if (errors is Map<String, dynamic>) {
      final validityError = _extractFirstString(
        errors['orc_dias_validade'] ?? errors['dias_validade'],
      );
      if (validityError != null) {
        return validityError;
      }
    }

    final firstError = _extractFirstString(errors);
    if (firstError != null) {
      return firstError;
    }

    final containsValidityKey = payload.toString().contains('orc_dias_validade') ||
        payload.toString().contains('dias_validade');
    if (containsValidityKey) {
      return 'Validade do orçamento deve estar entre 1 e 365 dias';
    }

    final generic = payload['mensagem'] ?? payload['message'] ?? payload['error'];
    if (generic is String && generic.trim().isNotEmpty) {
      return generic.trim();
    }

    return fallback;
  }

  String? _extractFirstString(dynamic value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    if (value is List) {
      for (final item in value) {
        final extracted = _extractFirstString(item);
        if (extracted != null) return extracted;
      }
      return null;
    }

    if (value is Map) {
      for (final entryValue in value.values) {
        final extracted = _extractFirstString(entryValue);
        if (extracted != null) return extracted;
      }
    }

    return null;
  }
}
