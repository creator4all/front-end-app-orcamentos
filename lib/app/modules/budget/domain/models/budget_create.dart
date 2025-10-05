import 'product_selection.dart';

class BudgetCreateDto {
  final int diasValidade;
  final int usuarioId;
  final List<int> cidades;
  final int? cidadePrincipalId; // Tornado opcional
  final double total;
  final String? nome;
  final List<ProductSelectionDto> products;
  final int? partnerDestinoId; // ID do parceiro destino (apenas para admins)
  final List<Map<String, dynamic>>? indicadores; // Indicadores de censo

  BudgetCreateDto({
    required this.diasValidade,
    required this.usuarioId,
    this.cidades = const [],
    this.cidadePrincipalId,
    required this.total,
    this.nome,
    this.products = const [],
    this.partnerDestinoId,
    this.indicadores,
  });

  Map<String, dynamic> toMap() {
    // Extrair apenas IDs dos produtos SELECIONADOS
    final produtosSelecionados = products
        .where((p) => p.selected)
        .map((p) => p.produtoId)
        .toList();

    return {
      'orc_dias_validade': diasValidade,
      'orc_usuario_id': usuarioId,
      if (cidades.isNotEmpty) 'cidades': cidades,
      if (cidadePrincipalId != null) 'orc_cidade_id': cidadePrincipalId,
      'orc_total': total,
      if (nome != null && nome!.isNotEmpty) 'orc_nome': nome,
      'produtos_selecionados': produtosSelecionados,
      if (partnerDestinoId != null) 'orc_partner_destino_id': partnerDestinoId,
      if (indicadores != null && indicadores!.isNotEmpty) 'indicadores': indicadores,
    };
  }
}
