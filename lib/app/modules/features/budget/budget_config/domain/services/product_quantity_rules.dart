class ProductQuantityRules {
  static const int maxQuantity = 99999999;

  static const int maxQuantityDigits = 8;

  static double clamp(double quantity) {
    if (quantity.isNaN || quantity <= 0) return 0;
    return quantity > maxQuantity ? maxQuantity.toDouble() : quantity;
  }
}
