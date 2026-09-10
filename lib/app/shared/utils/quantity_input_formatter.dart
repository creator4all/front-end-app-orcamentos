import 'package:flutter/services.dart';

import 'quantity_utils.dart';

/// Aplica o separador de milhar pt-BR enquanto o usuário digita (99.999.999).
///
/// Também descarta qualquer caractere não numérico, o que dispensa combinar
/// este formatter com `FilteringTextInputFormatter.digitsOnly`.
class QuantityInputFormatter extends TextInputFormatter {
  const QuantityInputFormatter({this.maxDigits});

  /// Número máximo de dígitos aceitos, sem contar os pontos da máscara.
  final int? maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = QuantityUtils.digitsOnly(newValue.text);

    final limit = maxDigits;
    if (limit != null && digits.length > limit) {
      digits = digits.substring(0, limit);
    }

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final value = int.tryParse(digits);
    if (value == null) return oldValue;

    final text = QuantityUtils.format(value);

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
