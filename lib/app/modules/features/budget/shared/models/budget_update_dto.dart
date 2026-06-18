import 'package:equatable/equatable.dart';

import 'indicador_update_dto.dart';
import 'product_selection_update_dto.dart';

class BudgetUpdateDto extends Equatable {
  final String? nome;

  final int? diasValidade;

  final String? status;

  final bool? isArchived;

  final double? total;

  final int? usuarioId;

  final int? cidadeId;

  final List<int>? cidades;

  final List<IndicadorUpdateDto>? indicadores;

  final List<ProductSelectionUpdateDto>? produtos;

  final int? partnerDestinoId;

  const BudgetUpdateDto({
    this.nome,
    this.diasValidade,
    this.status,
    this.isArchived,
    this.total,
    this.usuarioId,
    this.cidadeId,
    this.cidades,
    this.indicadores,
    this.produtos,
    this.partnerDestinoId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (nome != null) map['orc_nome'] = nome;
    if (diasValidade != null) map['orc_dias_validade'] = diasValidade;
    if (status != null) map['orc_status'] = status;
    if (isArchived != null) map['isArchived'] = isArchived;
    if (total != null) map['orc_total'] = total;
    if (usuarioId != null) map['orc_usuario_id'] = usuarioId;
    if (cidadeId != null) map['orc_cidade_id'] = cidadeId;
    if (cidades != null) map['cidades'] = cidades;
    if (indicadores != null) {
      map['indicadores'] = indicadores!.map((i) => i.toJson()).toList();
    }
    if (produtos != null && produtos!.isNotEmpty) {
      map['produtos'] = produtos!.map((p) => p.toJson()).toList();
    }
    if (partnerDestinoId != null) {
      map['orc_partner_destino_id'] = partnerDestinoId;
    }

    return map;
  }

  Map<String, dynamic> toJsonForMultiCity() {
    final map = <String, dynamic>{};

    if (nome != null) map['orc_nome'] = nome;
    if (diasValidade != null) map['orc_dias_validade'] = diasValidade;
    if (status != null) map['orc_status'] = status;
    if (isArchived != null) map['isArchived'] = isArchived;
    if (total != null) map['orc_total'] = total;
    if (usuarioId != null) map['orc_usuario_id'] = usuarioId;

    if (cidades != null) {
      map['cidades'] =
          cidades!.map((id) => {'cidade_id': id, 'overrides': null}).toList();
    }

    if (produtos != null && produtos!.isNotEmpty) {
      map['produtos'] = produtos!.map((p) => p.toJsonForMultiCity()).toList();
    }

    if (partnerDestinoId != null) {
      map['orc_partner_destino_id'] = partnerDestinoId;
    }

    return map;
  }

  @override
  List<Object?> get props => [
        nome,
        diasValidade,
        status,
        isArchived,
        total,
        usuarioId,
        cidadeId,
        cidades,
        indicadores,
        produtos,
        partnerDestinoId,
      ];

  @override
  String toString() {
    return 'BudgetUpdateDto('
        'nome: $nome, '
        'diasValidade: $diasValidade, '
        'status: $status, '
        'isArchived: $isArchived, '
        'total: $total, '
        'cidades: ${cidades?.length ?? 0}, '
        'indicadores: ${indicadores?.length ?? 0}, '
        'produtos: ${produtos?.length ?? 0}, '
        'partnerDestinoId: $partnerDestinoId'
        ')';
  }
}
