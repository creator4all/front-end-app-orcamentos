import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';

import '../../../budget_config/domain/entities/category_entity.dart';
import 'cidade_entity.dart';
import 'location_entity.dart';
import 'orcamento_produto_entity.dart';

part 'budget_draft_entity.g.dart';

@CopyWith()
class BudgetDraftEntity extends Equatable {
  final int id;
  final int?
      partnerId;
  final String partnerName;
  final LocationEntity location;
  final String? responsibleName;
  final String? responsibleEmail;
  final DateTime? validityDate;
  final String status;
  final DateTime createdAt;
  final int createdByUserId;
  final int validityDays;
  final double total;
  final bool createdByAdmin;
  final DateTime dataValidade;
  final CidadeEntity? cidade;
  final List<OrcamentoProdutoEntity> orcamentoProdutos;
  final List<CategoryEntity> categories;

  const BudgetDraftEntity({
    required this.id,
    this.partnerId,
    required this.partnerName,
    required this.location,
    this.responsibleName,
    this.responsibleEmail,
    this.validityDate,
    required this.status,
    required this.createdAt,
    required this.createdByUserId,
    required this.validityDays,
    required this.total,
    required this.createdByAdmin,
    required this.dataValidade,
    this.cidade,
    required this.orcamentoProdutos,
    this.categories = const [],
  });

  bool get isDraft => status.toLowerCase() == 'rascunho';

  bool get hasResponsible =>
      responsibleName != null && responsibleName!.isNotEmpty;

  bool get hasResponsibleEmail =>
      responsibleEmail != null && responsibleEmail!.isNotEmpty;

  bool get hasValidityDate => validityDate != null;
  bool get isValidityInFuture =>
      validityDate != null && validityDate!.isAfter(DateTime.now());

  bool get hasPartnerDestino => partnerId != null && partnerId! > 0;

  String get responsibleDisplay => responsibleName ?? 'Não informado';

  String get emailDisplay => responsibleEmail ?? 'Não informado';

  bool canBeConfigure() => isDraft;

  @override
  List<Object?> get props => [
        id,
        partnerId,
        partnerName,
        location,
        responsibleName,
        responsibleEmail,
        validityDate,
        status,
        createdAt,
        createdByUserId,
      ];

  @override
  bool get stringify => true;
}
