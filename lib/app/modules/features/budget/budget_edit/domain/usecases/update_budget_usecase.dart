import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../../../shared/models/budget_update_dto.dart';
import '../entities/budget_edit_entity.dart';
import '../repositories/budget_edit_repository.dart';

/// Caso de uso para atualizar um orçamento
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
    // Validações
    if (budgetId <= 0) {
      return const Left(ValidationFailure('ID do orçamento inválido'));
    }

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

  /// Atualiza orçamento usando DTO completo
  ///
  /// Método recomendado para atualizações completas incluindo:
  /// - Produtos (seleção e quantidade)
  /// - Indicadores do Censo Escolar
  /// - Dados gerais (nome, status, validade, total)
  ///
  /// [budgetId] ID do orçamento a atualizar
  /// [updateData] DTO com dados para atualização (partial update)
  ///
  /// Retorna o orçamento atualizado ou falha
  Future<Either<BudgetFailure, BudgetEditEntity>> callWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  }) async {
    try {
      // Validação: ID válido
      if (budgetId <= 0) {
        return const Left(ValidationFailure('ID do orçamento inválido'));
      }

      // Validação: Dias de validade se fornecido
      if (updateData.diasValidade != null &&
          (updateData.diasValidade! < 1 || updateData.diasValidade! > 365)) {
        return const Left(
          ValidationFailure('Validade deve estar entre 1 e 365 dias'),
        );
      }

      // Validação: Total se fornecido
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

  /// Cria nova versão do orçamento com as alterações
  ///
  /// O orçamento original permanece inalterado e uma nova versão
  /// é criada com as alterações fornecidas.
  ///
  /// [budgetId] ID do orçamento a versionar
  /// [updateData] DTO com dados da nova versão
  ///
  /// Retorna a nova versão do orçamento ou falha
  Future<Either<BudgetFailure, BudgetEditEntity>> versionWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  }) async {
    try {
      // Validação: ID válido
      if (budgetId <= 0) {
        return const Left(ValidationFailure('ID do orçamento inválido'));
      }

      // Validação: Dias de validade se fornecido
      if (updateData.diasValidade != null &&
          (updateData.diasValidade! < 1 || updateData.diasValidade! > 365)) {
        return const Left(
          ValidationFailure('Validade deve estar entre 1 e 365 dias'),
        );
      }

      // Validação: Total se fornecido
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

  /// Cria nova versão de orçamento MULTI-CIDADE
  ///
  /// Usa endpoint específico para orçamentos com múltiplas cidades.
  ///
  /// [budgetId] ID do orçamento a versionar
  /// [updateData] DTO com dados da nova versão (incluindo array cidades)
  ///
  /// Retorna a nova versão do orçamento ou falha
  Future<Either<BudgetFailure, BudgetEditEntity>> versionMultiCityWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  }) async {
    try {
      // Validação: ID válido
      if (budgetId <= 0) {
        return const Left(ValidationFailure('ID do orçamento inválido'));
      }

      // Validação: Dias de validade se fornecido
      if (updateData.diasValidade != null &&
          (updateData.diasValidade! < 1 || updateData.diasValidade! > 365)) {
        return const Left(
          ValidationFailure('Validade deve estar entre 1 e 365 dias'),
        );
      }

      // Validação: Total se fornecido
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
