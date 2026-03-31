import 'package:dartz/dartz.dart';

import '../../../shared/errors/budget_failure.dart';
import '../entities/budget_draft_entity.dart';

class CreateBudgetDraftParams {
  final int partnerId;
  final int userId;
  final String stateCode;
  final String cityCode;
  final int cityId;
  final String cityName;
  final String stateUf;
  final String? responsibleName;
  final String? responsibleEmail;
  final DateTime? validityDate;
  final double total;

  const CreateBudgetDraftParams({
    required this.partnerId,
    required this.userId,
    required this.stateCode,
    required this.cityCode,
    required this.cityId,
    required this.cityName,
    required this.stateUf,
    this.responsibleName,
    this.responsibleEmail,
    this.validityDate,
    this.total = 0.0,
  });

  bool get isValid =>
      partnerId > 0 &&
      userId > 0 &&
      stateCode.isNotEmpty &&
      cityCode.isNotEmpty;

  Map<String, dynamic> toJson() {
    final validity =
        validityDate ?? DateTime.now().add(const Duration(days: 60));
    final hoje = DateTime.now();
    final hojeNormalizado = DateTime(hoje.year, hoje.month, hoje.day);
    final validadeNormalizada =
        DateTime(validity.year, validity.month, validity.day);
    final diasValidade = validadeNormalizada.difference(hojeNormalizado).inDays;

    final Map<String, dynamic> data = {
      'orc_partner_destino_id': partnerId,
      'orc_usuario_id': userId,
      'orc_cidade_id': cityId,
      'orc_status': 'rascunho',
      'orc_total': total,
      'orc_dias_validade': diasValidade.clamp(1, 365),
      'orc_nome': stateUf.trim().isNotEmpty ? '$cityName - ${stateUf.trim()}' : cityName,
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

abstract class BudgetDraftRepository {
  Future<Either<BudgetFailure, BudgetDraftEntity>> createDraft(
    CreateBudgetDraftParams params,
  );

  Future<Either<BudgetFailure, BudgetDraftEntity>> getDraftById(int budgetId);
}
