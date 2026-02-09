import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';

part 'product_selection_entity.g.dart';

/// Entidade que representa um produto selecionado no orçamento
@CopyWith()
class ProductSelectionEntity extends Equatable {
  /// ID do produto
  final int productId;

  /// Nome do produto
  final String name;

  /// Categoria do produto (livros, portal, gamificação, etc)
  final String category;

  /// Preço unitário
  final double price;

  /// Se o produto está selecionado
  final bool isSelected;

  /// Quantidade (opcional)
  final int? quantity;

  const ProductSelectionEntity({
    required this.productId,
    required this.name,
    required this.category,
    required this.price,
    required this.isSelected,
    this.quantity,
  });

  // ========== Regras de Negócio ==========

  /// Calcula o preço total (preço * quantidade)
  double get totalPrice => price * (quantity ?? 1);

  @override
  List<Object?> get props => [
        productId,
        name,
        category,
        price,
        isSelected,
        quantity,
      ];
}
