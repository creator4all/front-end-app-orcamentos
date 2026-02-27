import '../entities/product_selection_entity.dart';

class CalculateTotalsUseCase {
  double call(List<ProductSelectionEntity> products) {
    return products
        .where((product) => product.isSelected)
        .fold(0.0, (sum, product) => sum + product.totalPrice);
  }

  Map<String, double> calculateByCategory(
    List<ProductSelectionEntity> products,
    Map<String, bool> categoryStates,
  ) {
    final totals = <String, double>{};

    for (final product in products) {
      if (!product.isSelected) continue;

      final categoryActive = categoryStates[product.category] ?? false;
      if (!categoryActive) continue;

      totals[product.category] =
          (totals[product.category] ?? 0.0) + product.totalPrice;
    }

    return totals;
  }

  int countSelectedProducts(List<ProductSelectionEntity> products) {
    return products.where((p) => p.isSelected).length;
  }

  Map<String, int> countByCategory(
    List<ProductSelectionEntity> products,
    Map<String, bool> categoryStates,
  ) {
    final counts = <String, int>{};

    for (final product in products) {
      if (!product.isSelected) continue;

      final categoryActive = categoryStates[product.category] ?? false;
      if (!categoryActive) continue;

      counts[product.category] = (counts[product.category] ?? 0) + 1;
    }

    return counts;
  }
}
