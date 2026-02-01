import 'package:intl/intl.dart';

/// Utilitários para formatação de valores monetários
class CurrencyUtils {
  CurrencyUtils._();

  static final _brlFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  /// Formata valor para Real brasileiro (R$ 1.234,56)
  static String formatBRL(double value) => _brlFormatter.format(value);
}
