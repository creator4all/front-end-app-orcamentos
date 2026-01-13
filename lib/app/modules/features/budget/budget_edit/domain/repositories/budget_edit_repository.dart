import 'package:dartz/dartz.dart';

import '../../../budget_config/domain/entities/product_entity.dart';
import '../../../shared/errors/budget_failure.dart';
import '../../../shared/models/budget_update_dto.dart';
import '../entities/budget_edit_entity.dart';

/// Contrato abstrato para operações de edição de orçamento
abstract class BudgetEditRepository {
  /// Busca os detalhes completos de um orçamento para edição (estrutura)
  Future<Either<BudgetFailure, BudgetEditEntity>> getBudgetForEdit(int id);

  /// Busca TODOS os produtos do orçamento com seus estados reais do banco
  Future<Either<BudgetFailure, List<ProductEntity>>> getAllProducts({
    required int budgetId,
  });

  /// Atualiza um orçamento existente (Método legado)
  ///
  /// **DEPRECATED**: Use [updateBudgetWithDto] para maior flexibilidade
  @Deprecated('Use updateBudgetWithDto')
  Future<Either<BudgetFailure, BudgetEditEntity>> updateBudget({
    required int id,
    String? name,
    int? validityDays,
    DateTime? validityDate,
    String? status,
    bool? isArchived,
    List<int>? selectedProductIds,
  });

  /// Atualiza um orçamento usando DTO completo
  ///
  /// Permite atualização de produtos, status, dados gerais e indicadores
  ///
  /// [budgetId] ID do orçamento a atualizar
  /// [updateData] DTO com dados para atualização (partial update)
  ///
  /// Retorna o orçamento atualizado ou falha
  Future<Either<BudgetFailure, BudgetEditEntity>> updateBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  });

  /// Cria nova versão do orçamento com as alterações
  ///
  /// O orçamento original permanece inalterado e uma nova versão
  /// é criada com as alterações fornecidas.
  ///
  /// [budgetId] ID do orçamento a versionar
  /// [updateData] DTO com dados da nova versão
  ///
  /// Retorna a nova versão do orçamento ou falha
  Future<Either<BudgetFailure, BudgetEditEntity>> versionBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  });

  /// Cria nova versão de orçamento MULTI-CIDADE
  ///
  /// Endpoint específico para orçamentos com múltiplas cidades.
  ///
  /// [budgetId] ID do orçamento a versionar
  /// [updateData] DTO com dados da nova versão (incluindo array cidades)
  ///
  /// Retorna a nova versão do orçamento ou falha
  Future<Either<BudgetFailure, BudgetEditEntity>>
  versionMultiCityBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  });
}
