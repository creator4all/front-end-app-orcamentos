import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/services/budget_value_rules.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/services/product_quantity_rules.dart';

void main() {
  group('BudgetValueRules', () {
    test('should keep unit values inside the accepted range', () {
      expect(BudgetValueRules.clampUnitValue(0.01), 0.01);
      expect(BudgetValueRules.clampUnitValue(1234.56), 1234.56);
      expect(
        BudgetValueRules.clampUnitValue(BudgetValueRules.maxUnitValue),
        BudgetValueRules.maxUnitValue,
      );
    });

    test('should cap unit values above the op_valor column limit', () {
      expect(
        BudgetValueRules.clampUnitValue(16600000000000000),
        BudgetValueRules.maxUnitValue,
      );
    });

    test('should treat non positive and NaN unit values as zero', () {
      expect(BudgetValueRules.clampUnitValue(0), 0);
      expect(BudgetValueRules.clampUnitValue(-5), 0);
      expect(BudgetValueRules.clampUnitValue(double.nan), 0);
    });

    test('should accept totals up to the orc_total column limit', () {
      expect(BudgetValueRules.exceedsMaxTotal(0), isFalse);
      expect(BudgetValueRules.exceedsMaxTotal(2100000000), isFalse);
      expect(
        BudgetValueRules.exceedsMaxTotal(BudgetValueRules.maxTotal),
        isFalse,
      );
    });

    test('should reject totals above the orc_total column limit', () {
      expect(BudgetValueRules.exceedsMaxTotal(9.9609463650067e24), isTrue);
      expect(BudgetValueRules.exceedsMaxTotal(double.nan), isTrue);
      expect(BudgetValueRules.exceedsMaxTotal(double.infinity), isTrue);
    });

    test('should reject six products at the maximum quantity and value', () {
      const total = 6 *
          ProductQuantityRules.maxQuantity *
          BudgetValueRules.maxUnitValue;

      expect(BudgetValueRules.exceedsMaxTotal(total), isTrue);
    });

    test('should keep the digit limit aligned with the maximum unit value', () {
      expect(
        (BudgetValueRules.maxUnitValue * 100).round().toString().length,
        BudgetValueRules.maxUnitValueDigits,
      );
    });
  });
}
