import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/budget_draft_entity.dart';

/// Dados necessários para criar um orçamento em rascunho
class CreateBudgetDraftParams {
  final int partnerId;
  final String stateCode;
  final String cityCode;
  final String? responsibleName;
  final String? responsibleEmail;
  final DateTime? validityDate;

  const CreateBudgetDraftParams({
    required this.partnerId,
    required this.stateCode,
    required this.cityCode,
    this.responsibleName,
    this.responsibleEmail,
    this.validityDate,
  });

  /// Validação dos dados obrigatórios
  bool get isValid =>
      partnerId > 0 && stateCode.isNotEmpty && cityCode.isNotEmpty;

  /// Converte para Map para envio à API
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'orc_parceiro_id': partnerId,
      'orc_estado': stateCode,
      'orc_cidade': cityCode,
      'orc_status': 'rascunho',
    };

    if (responsibleName != null && responsibleName!.isNotEmpty) {
      data['orc_responsavel_nome'] = responsibleName;
    }

    if (responsibleEmail != null && responsibleEmail!.isNotEmpty) {
      data['orc_responsavel_email'] = responsibleEmail;
    }

    if (validityDate != null) {
      data['orc_validade'] = validityDate!.toIso8601String().split('T')[0];
    }

    return data;
  }
}

/// Repositório abstrato para operações com Orçamentos em Rascunho
/// Define os contratos que devem ser implementados pela camada de dados
abstract class BudgetDraftRepository {
  /// Cria um novo orçamento em rascunho
  /// Retorna Either<BudgetFailure, BudgetDraftEntity>
  Future<Either<BudgetFailure, BudgetDraftEntity>> createDraft(
    CreateBudgetDraftParams params,
  );

  /// Busca um orçamento em rascunho por ID
  /// Retorna Either<BudgetFailure, BudgetDraftEntity>
  Future<Either<BudgetFailure, BudgetDraftEntity>> getDraftById(int budgetId);

  /// Valida se um orçamento pode ser criado
  /// Verifica regras de negócio antes da criação
  Future<Either<BudgetFailure, bool>> validateBudgetCreation(
    CreateBudgetDraftParams params,
  );
}
