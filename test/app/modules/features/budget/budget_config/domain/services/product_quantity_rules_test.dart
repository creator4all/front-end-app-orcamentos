import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/services/product_quantity_rules.dart';

void main() {
  group('ProductQuantityRules', () {
    test('should keep quantities inside the accepted range', () {
      expect(ProductQuantityRules.clamp(1), 1);
      expect(ProductQuantityRules.clamp(1234.5), 1234.5);
      expect(
        ProductQuantityRules.clamp(ProductQuantityRules.maxQuantity.toDouble()),
        ProductQuantityRules.maxQuantity,
      );
    });

    test('should cap quantities above the webservice limit', () {
      expect(
        ProductQuantityRules.clamp(100000000),
        ProductQuantityRules.maxQuantity,
      );
      expect(
        ProductQuantityRules.clamp(9999999999999),
        ProductQuantityRules.maxQuantity,
      );
    });

    test('should treat non positive and NaN values as zero', () {
      expect(ProductQuantityRules.clamp(0), 0);
      expect(ProductQuantityRules.clamp(-5), 0);
      expect(ProductQuantityRules.clamp(double.nan), 0);
    });

    test('should keep the digit limit aligned with the maximum quantity', () {
      expect(
        ProductQuantityRules.maxQuantity.toString().length,
        ProductQuantityRules.maxQuantityDigits,
      );
    });
  });
}
