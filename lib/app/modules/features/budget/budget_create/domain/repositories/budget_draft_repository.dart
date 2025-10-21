import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/budget_draft_entity.dart';

/// Dados necessários para criar um orçamento em rascunho
class CreateBudgetDraftParams {
  final int partnerId;
  final int userId; // ID do usuário criando o orçamento (OBRIGATÓRIO)
  final String stateCode;
  final String cityCode;
  final String? responsibleName;
  final String? responsibleEmail;
  final DateTime? validityDate;
  final double total; // Total do orçamento (pode ser 0 para rascunho)

  const CreateBudgetDraftParams({
    required this.partnerId,
    required this.userId,
    required this.stateCode,
    required this.cityCode,
    this.responsibleName,
    this.responsibleEmail,
    this.validityDate,
    this.total = 0.0, // Padrão 0 para rascunho
  });

  /// Validação dos dados obrigatórios
  bool get isValid =>
      partnerId > 0 &&
      userId > 0 &&
      stateCode.isNotEmpty &&
      cityCode.isNotEmpty;

  /// Converte para Map para envio à API
  Map<String, dynamic> toJson() {
    // Calcula dias de validade (60 dias a partir de hoje se não especificado)
    final validity =
        validityDate ?? DateTime.now().add(const Duration(days: 60));
    final now = DateTime.now();
    final diasValidade = validity.difference(now).inDays;

    final Map<String, dynamic> data = {
      'orc_parceiro_id': partnerId,
      'orc_usuario_id': userId, // ✅ Campo obrigatório
      'cidades': [int.parse(cityCode)], // ✅ Backend espera array de IDs
      'orc_status': 'rascunho',
      'orc_total': total, // ✅ Campo obrigatório (pode ser 0)
      'orc_dias_validade': diasValidade.clamp(1, 365), // ✅ Entre 1 e 365 dias
    };

    if (responsibleName != null && responsibleName!.isNotEmpty) {
      data['orc_responsavel_nome'] = responsibleName;
    }

    if (responsibleEmail != null && responsibleEmail!.isNotEmpty) {
      data['orc_responsavel_email'] = responsibleEmail;
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
