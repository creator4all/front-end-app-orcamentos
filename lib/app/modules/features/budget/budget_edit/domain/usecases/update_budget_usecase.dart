import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../../../shared/models/budget_update_dto.dart';
import '../entities/budget_edit_entity.dart';
import '../repositories/budget_edit_repository.dart';

class UpdateBudgetUseCase {
  final BudgetEditRepository repository;

  UpdateBudgetUseCase(this.repository);

  Future<Either<BudgetFailure, BudgetEditEntity>> call({
    required int budgetId,
    String? name,
    int? validityDays,
    DateTime? validityDate,
    String? status,
    bool? isArchived,
    List<int>? selectedProductIds,
  }) async {
    if (validityDays != null && (validityDays < 1 || validityDays > 365)) {
      return const Left(
        ValidationFailure('Validade deve estar entre 1 e 365 dias'),
      );
    }

    if (validityDate != null && validityDate.isBefore(DateTime.now())) {
      return const Left(
        ValidationFailure('Data de validade não pode ser no passado'),
      );
    }

    return await repository.updateBudget(
      id: budgetId,
      name: name,
      validityDays: validityDays,
      validityDate: validityDate,
      status: status,
      isArchived: isArchived,
      selectedProductIds: selectedProductIds,
    );
  }

  Future<Either<BudgetFailure, BudgetEditEntity>> callWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  }) async {
    try {
      if (updateData.diasValidade != null &&
          (updateData.diasValidade! < 1 || updateData.diasValidade! > 365)) {
        return const Left(
          ValidationFailure('Validade deve estar entre 1 e 365 dias'),
        );
      }

      if (updateData.total != null && updateData.total! < 0) {
        return const Left(
          ValidationFailure('O valor total não pode ser negativo'),
        );
      }

      return await repository.updateBudgetWithDto(
        budgetId: budgetId,
        updateData: updateData,
      );
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<BudgetFailure, BudgetEditEntity>> versionWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  }) async {
    try {
      if (updateData.diasValidade != null &&
          (updateData.diasValidade! < 1 || updateData.diasValidade! > 365)) {
        return const Left(
          ValidationFailure('Validade deve estar entre 1 e 365 dias'),
        );
      }

      if (updateData.total != null && updateData.total! < 0) {
        return const Left(
          ValidationFailure('O valor total não pode ser negativo'),
        );
      }

      return await repository.versionBudgetWithDto(
        budgetId: budgetId,
        updateData: updateData,
      );
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<BudgetFailure, BudgetEditEntity>> versionMultiCityWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  }) async {
    try {
      if (updateData.diasValidade != null &&
          (updateData.diasValidade! < 1 || updateData.diasValidade! > 365)) {
        return const Left(
          ValidationFailure('Validade deve estar entre 1 e 365 dias'),
        );
      }

      if (updateData.total != null && updateData.total! < 0) {
        return const Left(
          ValidationFailure('O valor total não pode ser negativo'),
        );
      }

      return await repository.versionMultiCityBudgetWithDto(
        budgetId: budgetId,
        updateData: updateData,
      );
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
