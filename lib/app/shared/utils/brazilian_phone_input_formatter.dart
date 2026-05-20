import 'package:flutter/services.dart';

class BrazilianPhoneInputFormatter extends TextInputFormatter {
  static String digitsOnly(String value) {
    final digits = _normalizedDigits(value);
    return digits.length > 11 ? digits.substring(0, 11) : digits;
  }

  static String _rawDigitsOnly(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static String _normalizedDigits(String value) {
    final digits = _rawDigitsOnly(value);
    if (digits.length > 11 && digits.startsWith('55')) {
      return digits.substring(2);
    }
    return digits;
  }

  static String format(String value) {
    final digits = digitsOnly(value);

    if (digits.isEmpty) {
      return '';
    }

    if (digits.length <= 2) {
      return '($digits';
    }

    final ddd = digits.substring(0, 2);
    final number = digits.substring(2);
    final prefix = '($ddd) ';

    if (number.length <= 4) {
      return '$prefix$number';
    }

    if (digits.length <= 10) {
      return '$prefix${number.substring(0, 4)}-${number.substring(4)}';
    }

    return '$prefix${number.substring(0, 5)}-${number.substring(5)}';
  }

  static bool isValid(String value) {
    final digits = _normalizedDigits(value);
    return digits.length == 10 || digits.length == 11;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = format(newValue.text);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
