import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/shared/utils/brazilian_phone_input_formatter.dart';

void main() {
  group('BrazilianPhoneInputFormatter', () {
    test('formats landline phone numbers', () {
      expect(
        BrazilianPhoneInputFormatter.format('1888159765'),
        '(18) 8815-9765',
      );
    });

    test('formats mobile phone numbers', () {
      expect(
        BrazilianPhoneInputFormatter.format('18988159765'),
        '(18) 98815-9765',
      );
    });

    test('formats numbers with Brazil country code', () {
      expect(
        BrazilianPhoneInputFormatter.format('+55 (18) 98815-9765'),
        '(18) 98815-9765',
      );
    });

    test('limits input to 11 digits', () {
      expect(
        BrazilianPhoneInputFormatter.digitsOnly('(18) 98815-976599'),
        '18988159765',
      );
    });

    test('accepts only 10 or 11 digit phone numbers', () {
      expect(BrazilianPhoneInputFormatter.isValid('(18) 8815-9765'), isTrue);
      expect(BrazilianPhoneInputFormatter.isValid('(18) 98815-9765'), isTrue);
      expect(BrazilianPhoneInputFormatter.isValid('(18) 815-9765'), isFalse);
      expect(
        BrazilianPhoneInputFormatter.isValid('(18) 98815-976599'),
        isFalse,
      );
    });
  });
}
