import 'package:equatable/equatable.dart';

import 'location_entity.dart';

/// Entidade que representa um Orçamento em Rascunho
class BudgetDraftEntity extends Equatable {
  final int id;
  final int partnerId;
  final String partnerName;
  final LocationEntity location;
  final String? responsibleName;
  final String? responsibleEmail;
  final DateTime? validityDate;
  final String status; // 'rascunho'
  final DateTime createdAt;
  final int createdByUserId;

  const BudgetDraftEntity({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    required this.location,
    this.responsibleName,
    this.responsibleEmail,
    this.validityDate,
    required this.status,
    required this.createdAt,
    required this.createdByUserId,
  });

  /// Verifica se o orçamento está em estado de rascunho
  bool get isDraft => status.toLowerCase() == 'rascunho';

  /// Verifica se tem responsável definido
  bool get hasResponsible =>
      responsibleName != null && responsibleName!.isNotEmpty;

  /// Verifica se tem email do responsável
  bool get hasResponsibleEmail =>
      responsibleEmail != null && responsibleEmail!.isNotEmpty;

  /// Verifica se tem data de validade
  bool get hasValidityDate => validityDate != null;

  /// Verifica se a validade está no futuro
  bool get isValidityInFuture =>
      validityDate != null && validityDate!.isAfter(DateTime.now());

  /// Retorna o nome formatado do responsável
  String get responsibleDisplay => responsibleName ?? 'Não informado';

  /// Retorna o email formatado do responsável
  String get emailDisplay => responsibleEmail ?? 'Não informado';

  /// Verifica se o orçamento pode ser configurado
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

  BudgetDraftEntity copyWith({
    int? id,
    int? partnerId,
    String? partnerName,
    LocationEntity? location,
    String? responsibleName,
    String? responsibleEmail,
    DateTime? validityDate,
    String? status,
    DateTime? createdAt,
    int? createdByUserId,
  }) {
    return BudgetDraftEntity(
      id: id ?? this.id,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      location: location ?? this.location,
      responsibleName: responsibleName ?? this.responsibleName,
      responsibleEmail: responsibleEmail ?? this.responsibleEmail,
      validityDate: validityDate ?? this.validityDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      createdByUserId: createdByUserId ?? this.createdByUserId,
    );
  }
}
