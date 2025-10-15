import '../../domain/entities/product_selection_entity.dart';

/// DTO para produto selecionado
/// Responsável pela conversão JSON <-> Entity
class ProductSelectionDto {
  final int productId;
  final String name;
  final String category;
  final double price;
  final bool isSelected;
  final int? quantity;

  ProductSelectionDto({
    required this.productId,
    required this.name,
    required this.category,
    required this.price,
    required this.isSelected,
    this.quantity,
  });

  /// Cria DTO a partir do JSON da API
  factory ProductSelectionDto.fromJson(Map<String, dynamic> json) {
    return ProductSelectionDto(
      productId: json['id'] ?? json['produto_id'] ?? 0,
      name: json['nome'] ?? json['name'] ?? '',
      category: json['categoria'] ?? json['category'] ?? '',
      price: (json['preco'] ?? json['price'] ?? 0.0).toDouble(),
      isSelected: json['selecionado'] ?? json['is_selected'] ?? false,
      quantity: json['quantidade'] ?? json['quantity'],
    );
  }

  /// Converte DTO para JSON
  Map<String, dynamic> toJson() {
    return {
      'produto_id': productId,
      'nome': name,
      'categoria': category,
      'preco': price,
      'selecionado': isSelected,
      if (quantity != null) 'quantidade': quantity,
    };
  }

  /// Converte DTO para Entity
  ProductSelectionEntity toEntity() {
    return ProductSelectionEntity(
      productId: productId,
      name: name,
      category: category,
      price: price,
      isSelected: isSelected,
      quantity: quantity,
    );
  }

  /// Cria DTO a partir de Entity
  factory ProductSelectionDto.fromEntity(ProductSelectionEntity entity) {
    return ProductSelectionDto(
      productId: entity.productId,
      name: entity.name,
      category: entity.category,
      price: entity.price,
      isSelected: entity.isSelected,
      quantity: entity.quantity,
    );
  }
}
