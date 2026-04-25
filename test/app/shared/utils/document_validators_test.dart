import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/shared/utils/document_validators.dart';

void main() {
  group('DocumentValidators', () {
    group('isValidCPF', () {
      test('should return true for valid CPF', () {
        // CPFs válidos para teste
        expect(DocumentValidators.isValidCPF('12345678909'), isTrue);
        expect(DocumentValidators.isValidCPF('11144477735'), isTrue);
        expect(DocumentValidators.isValidCPF('00000000191'), isTrue);
      });

      test('should return false for CPF with all same digits', () {
        expect(DocumentValidators.isValidCPF('11111111111'), isFalse);
        expect(DocumentValidators.isValidCPF('00000000000'), isFalse);
        expect(DocumentValidators.isValidCPF('99999999999'), isFalse);
      });

      test('should return false for invalid CPF', () {
        expect(DocumentValidators.isValidCPF('12345678900'), isFalse);
        expect(DocumentValidators.isValidCPF('11144477700'), isFalse);
        expect(DocumentValidators.isValidCPF('00000000192'), isFalse);
      });

      test('should return false for CPF with wrong length', () {
        expect(DocumentValidators.isValidCPF('1234567890'), isFalse);
        expect(DocumentValidators.isValidCPF('123456789012'), isFalse);
      });

      test('should handle formatted CPF', () {
        expect(DocumentValidators.isValidCPF('123.456.789-09'), isTrue);
        expect(DocumentValidators.isValidCPF('111.444.777-35'), isTrue);
      });
    });

    group('isValidCNPJ', () {
      test('should return true for valid CNPJ', () {
        // CNPJs válidos para teste
        expect(DocumentValidators.isValidCNPJ('11222333000181'), isTrue);
        expect(DocumentValidators.isValidCNPJ('11444777000161'), isTrue);
      });

      test('should return false for CNPJ with all same digits', () {
        expect(DocumentValidators.isValidCNPJ('00000000000000'), isFalse);
        expect(DocumentValidators.isValidCNPJ('11111111111111'), isFalse);
        expect(DocumentValidators.isValidCNPJ('99999999999999'), isFalse);
      });

      test('should return false for invalid CNPJ', () {
        expect(DocumentValidators.isValidCNPJ('11222333000180'), isFalse);
        expect(DocumentValidators.isValidCNPJ('11444777000160'), isFalse);
      });

      test('should return false for CNPJ with wrong length', () {
        expect(DocumentValidators.isValidCNPJ('1122233300018'), isFalse);
        expect(DocumentValidators.isValidCNPJ('112223330001810'), isFalse);
      });

      test('should handle formatted CNPJ', () {
        expect(DocumentValidators.isValidCNPJ('11.222.333/0001-81'), isTrue);
        expect(DocumentValidators.isValidCNPJ('11.444.777/0001-61'), isTrue);
      });
    });

    group('isValidDocument', () {
      test('should validate CPF when 11 digits', () {
        expect(DocumentValidators.isValidDocument('12345678909'), isTrue);
        expect(DocumentValidators.isValidDocument('12345678900'), isFalse);
      });

      test('should validate CNPJ when 14 digits', () {
        expect(DocumentValidators.isValidDocument('11222333000181'), isTrue);
        expect(DocumentValidators.isValidDocument('11222333000180'), isFalse);
      });

      test('should return false for wrong length', () {
        expect(DocumentValidators.isValidDocument('123456789'), isFalse);
        expect(DocumentValidators.isValidDocument('1234567890123'), isFalse);
      });
    });

    group('getDocumentError', () {
      test('should return null for valid CPF', () {
        expect(DocumentValidators.getDocumentError('12345678909'), isNull);
      });

      test('should return null for valid CNPJ', () {
        expect(DocumentValidators.getDocumentError('11222333000181'), isNull);
      });

      test('should return error for empty document', () {
        expect(DocumentValidators.getDocumentError(''), isNotNull);
      });

      test('should return error for invalid length', () {
        final error = DocumentValidators.getDocumentError('123456789');
        expect(error, contains('11 dígitos'));
        expect(error, contains('14 dígitos'));
      });

      test('should return error for invalid CPF', () {
        final error = DocumentValidators.getDocumentError('12345678900');
        expect(error, contains('CPF'));
        expect(error, contains('não é válido'));
      });

      test('should return error for invalid CNPJ', () {
        final error = DocumentValidators.getDocumentError('11222333000180');
        expect(error, contains('CNPJ'));
        expect(error, contains('não é válido'));
      });
    });

    group('formatDocument', () {
      test('should format CPF correctly', () {
        expect(
          DocumentValidators.formatDocument('12345678909'),
          equals('123.456.789-09'),
        );
      });

      test('should format CNPJ correctly', () {
        expect(
          DocumentValidators.formatDocument('11222333000181'),
          equals('11.222.333/0001-81'),
        );
      });

      test('should keep unexpected lengths as normalized digits', () {
        expect(
          DocumentValidators.formatDocument('123.456'),
          equals('123456'),
        );
      });
    });
  });
}
