class ProductSelectionDto {
  final int produtoId;
  final bool selected;
  final int? quantity;
  final double? price;

  ProductSelectionDto({
    required this.produtoId,
    required this.selected,
    this.quantity,
    this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'produto_id': produtoId,
      'selected': selected,
      if (quantity != null) 'quantity': quantity,
      if (price != null) 'price': price,
    };
  }
}
