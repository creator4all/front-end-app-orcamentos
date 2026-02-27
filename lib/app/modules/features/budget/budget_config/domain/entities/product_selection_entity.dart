import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';

part 'product_selection_entity.g.dart';

@CopyWith()
class ProductSelectionEntity extends Equatable {
  final int productId;

  final String name;

  final String category;

  final double price;

  final bool isSelected;

  final int? quantity;

  const ProductSelectionEntity({
    required this.productId,
    required this.name,
    required this.category,
    required this.price,
    required this.isSelected,
    this.quantity,
  });

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
