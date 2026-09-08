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

  /// Monta o corpo de `PUT /api/orcamentos/{id}`, também aceito por
  /// `POST /api/orcamentos/{id}/versionar`.
  ///
  /// O `PUT` valida atualização completa: todas as chaves do schema precisam
  /// estar presentes. Listas ausentes viram vazias — `cidades` e `indicadores`
  /// são validadas mas não consumidas pelo endpoint, e `produtos` vazio é
  /// tratado como "nada a sincronizar".
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'orc_nome': nome,
      'orc_dias_validade': diasValidade,
      'orc_status': status,
      'orc_total': total,
      'orc_usuario_id': usuarioId,
      'orc_partner_destino_id': partnerDestinoId,
      'isArchived': isArchived ?? false,
      'cidades': cidades ?? const <int>[],
      'indicadores':
          indicadores?.map((i) => i.toJson()).toList() ?? const <dynamic>[],
      'produtos':
          produtos?.map((p) => p.toJson()).toList() ?? const <dynamic>[],
    };

    if (cidadeId != null) map['orc_cidade_id'] = cidadeId;

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
      // `overrides` é opcional no contrato, mas quando presente precisa ser
      // uma lista — enviar `null` reprova a validação do versionamento.
      map['cidades'] = cidades!.map((id) => {'cidade_id': id}).toList();
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
