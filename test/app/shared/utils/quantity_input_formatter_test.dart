import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/shared/utils/quantity_input_formatter.dart';
import 'package:multimidiaapp/app/shared/utils/quantity_utils.dart';

TextEditingValue _type(String text) => TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );

void main() {
  group('QuantityUtils', () {
    test('should format with the pt-BR thousands separator', () {
      expect(QuantityUtils.format(1), '1');
      expect(QuantityUtils.format(999), '999');
      expect(QuantityUtils.format(1000), '1.000');
      expect(QuantityUtils.format(99999999), '99.999.999');
    });

    test('should truncate the decimal part', () {
      expect(QuantityUtils.format(1234.87), '1.234');
    });

    test('should read the integer back from a masked text', () {
      expect(QuantityUtils.parseToInt('99.999.999'), 99999999);
      expect(QuantityUtils.parseToInt('1.234'), 1234);
      expect(QuantityUtils.parseToInt(''), 0);
      expect(QuantityUtils.parseToInt('abc'), 0);
    });
  });

  group('QuantityInputFormatter', () {
    const formatter = QuantityInputFormatter(maxDigits: 8);

    TextEditingValue format(String text) => formatter.formatEditUpdate(
          const TextEditingValue(),
          _type(text),
        );

    test('should insert the separators while typing', () {
      expect(format('1').text, '1');
      expect(format('1234').text, '1.234');
      expect(format('1234567').text, '1.234.567');
    });

    test('should keep the caret at the end', () {
      final value = format('1234567');
      expect(value.selection.baseOffset, value.text.length);
    });

    test('should drop characters that are not digits', () {
      expect(format('1a2b3c4').text, '1.234');
    });

    test('should stop at the configured digit limit', () {
      expect(format('999999999999').text, '99.999.999');
    });

    test('should clear the field when every digit is removed', () {
      expect(format('').text, '');
      expect(format('...').text, '');
    });
  });
}
