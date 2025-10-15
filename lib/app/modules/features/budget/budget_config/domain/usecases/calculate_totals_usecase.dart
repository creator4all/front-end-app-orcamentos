import '../entities/product_selection_entity.dart';

/// Caso de uso para calcular totais do orçamento
///
/// Calcula valores baseado em produtos selecionados e categorias ativas
class CalculateTotalsUseCase {
  /// Calcula o valor total do orçamento
  ///
  /// Considera apenas produtos que estão marcados como selecionados
  double call(List<ProductSelectionEntity> products) {
    return products
        .where((product) => product.isSelected)
        .fold(0.0, (sum, product) => sum + product.totalPrice);
  }

  /// Calcula total por categoria
  ///
  /// Retorna um mapa com o total de cada categoria
  Map<String, double> calculateByCategory(
    List<ProductSelectionEntity> products,
    Map<String, bool> categoryStates,
  ) {
    final totals = <String, double>{};

    for (final product in products) {
      if (!product.isSelected) continue;

      // Verifica se a categoria está ativa
      final categoryActive = categoryStates[product.category] ?? false;
      if (!categoryActive) continue;

      totals[product.category] =
          (totals[product.category] ?? 0.0) + product.totalPrice;
    }

    return totals;
  }

  /// Calcula quantidade de produtos selecionados
  int countSelectedProducts(List<ProductSelectionEntity> products) {
    return products.where((p) => p.isSelected).length;
  }

  /// Calcula quantidade de produtos selecionados por categoria
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
