import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/shared/utils/brl_currency_input_formatter.dart';

TextEditingValue _type(String text) => TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );

void main() {
  group('BrlCurrencyInputFormatter', () {
    test('should format digits as pt-BR currency', () {
      final formatter = BrlCurrencyInputFormatter();

      final value = formatter.formatEditUpdate(
        const TextEditingValue(),
        _type('123456'),
      );

      expect(value.text, '1.234,56');
      expect(BrlCurrencyInputFormatter.parseToDouble(value.text), 1234.56);
    });

    test('should accept values up to the configured digit limit', () {
      final formatter = BrlCurrencyInputFormatter(maxDigits: 10);

      final value = formatter.formatEditUpdate(
        const TextEditingValue(),
        _type('9999999999'),
      );

      expect(value.text, '99.999.999,99');
    });

    test('should keep the previous value when the digit limit is exceeded', () {
      final formatter = BrlCurrencyInputFormatter(maxDigits: 10);
      final previous = _type('99.999.999,99');

      final value = formatter.formatEditUpdate(
        previous,
        _type('99.999.999,991'),
      );

      expect(value, previous);
    });
  });
}
