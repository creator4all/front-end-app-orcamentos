import 'package:intl/intl.dart';

/// Utilitários para formatação de valores monetários
class CurrencyUtils {
  CurrencyUtils._();

  static final _brlFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final _brlFormatterNoSymbol = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: '',
    decimalDigits: 2,
  );

  /// Formatter BRL (R$ 1.234,56) para uso direto com TextInputFormatter etc.
  static NumberFormat get brlFormatter => _brlFormatter;

  /// Formata valor para Real brasileiro (R$ 1.234,56)
  static String formatBRL(double value) => _brlFormatter.format(value);

  /// Formata valor sem símbolo (1.234,56) — usado em campos de input
  static String formatBRLNoSymbol(double value) =>
      _brlFormatterNoSymbol.format(value);
}
