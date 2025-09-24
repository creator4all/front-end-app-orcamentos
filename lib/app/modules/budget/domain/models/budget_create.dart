import 'product_selection.dart';

class BudgetCreateDto {
  final int diasValidade;
  final int usuarioId;
  final List<int> cidades;
  final int cidadePrincipalId;
  final double total;
  final String? nome;
  final List<ProductSelectionDto> products;

  BudgetCreateDto({
    required this.diasValidade,
    required this.usuarioId,
    required this.cidades,
    required this.cidadePrincipalId,
    required this.total,
    this.nome,
    this.products = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'orc_dias_validade': diasValidade,
      'orc_usuario_id': usuarioId,
      'cidades': cidades,
      'orc_cidade_id': cidadePrincipalId,
      'orc_total': total,
      if (nome != null && nome!.isNotEmpty) 'orc_nome': nome,
      'products': products.map((e) => e.toMap()).toList(),
    };
  }
}
