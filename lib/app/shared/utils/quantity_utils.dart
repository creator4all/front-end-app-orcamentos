import 'package:intl/intl.dart';

/// Utilitários para exibir e ler quantidades inteiras no padrão pt-BR.
///
/// Quantidades de orçamento chegam a milhões (o total é derivado do censo
/// escolar), então o agrupamento de milhar é o que torna o número legível.
class QuantityUtils {
  QuantityUtils._();

  static final _decimalFormatter = NumberFormat.decimalPattern('pt_BR');

  /// Formata a quantidade com separador de milhar (1.234.567).
  ///
  /// A parte decimal é descartada por truncamento. Quem precisa arredondar
  /// deve passar o valor já arredondado, para a política de arredondamento
  /// ficar visível em quem chama.
  static String format(num value) => _decimalFormatter.format(value.truncate());

  /// Remove a máscara, devolvendo apenas os dígitos.
  static String digitsOnly(String text) => text.replaceAll(RegExp(r'\D'), '');

  /// Converte um texto mascarado (1.234.567) no inteiro correspondente.
  static int parseToInt(String text) => int.tryParse(digitsOnly(text)) ?? 0;
}
