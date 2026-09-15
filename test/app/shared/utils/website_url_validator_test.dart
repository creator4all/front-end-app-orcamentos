import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/shared/utils/website_url_validator.dart';

void main() {
  group('WebsiteUrlValidator', () {
    group('normalize', () {
      test('should return null for empty or blank values', () {
        expect(WebsiteUrlValidator.normalize(''), isNull);
        expect(WebsiteUrlValidator.normalize('   '), isNull);
      });

      test('should add https scheme when the user omits it', () {
        expect(
          WebsiteUrlValidator.normalize('www.multimidia.com.br'),
          'https://www.multimidia.com.br',
        );
        expect(
          WebsiteUrlValidator.normalize('  multimidia.com.br/contato  '),
          'https://multimidia.com.br/contato',
        );
      });

      test('should keep an explicit scheme untouched', () {
        expect(
          WebsiteUrlValidator.normalize('http://multimidia.com.br'),
          'http://multimidia.com.br',
        );
        expect(
          WebsiteUrlValidator.normalize('https://multimidia.com.br'),
          'https://multimidia.com.br',
        );
      });
    });

    group('isValid', () {
      test('should accept an empty value because the field is optional', () {
        expect(WebsiteUrlValidator.isValid(''), isTrue);
        expect(WebsiteUrlValidator.isValid('   '), isTrue);
      });

      test('should accept a domain without scheme', () {
        expect(WebsiteUrlValidator.isValid('www.multimidia.com.br'), isTrue);
      });

      test('should reject values with spaces', () {
        expect(WebsiteUrlValidator.isValid('www.multi midia.com.br'), isFalse);
      });

      test('should reject schemes that the webservice does not accept', () {
        expect(WebsiteUrlValidator.isValid('ftp://multimidia.com.br'), isFalse);
      });

      test('should reject a value without host', () {
        expect(WebsiteUrlValidator.isValid('https://'), isFalse);
      });
    });

    group('getError', () {
      test('should return null when the value is acceptable', () {
        expect(WebsiteUrlValidator.getError(''), isNull);
        expect(WebsiteUrlValidator.getError('multimidia.com.br'), isNull);
      });

      test('should return a message when the value is invalid', () {
        expect(WebsiteUrlValidator.getError('ftp://multimidia.com.br'),
            isNotNull);
      });
    });
  });
}
