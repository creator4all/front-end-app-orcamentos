/// Limites monetários aceitos pelo webservice ao salvar um orçamento.
class BudgetValueRules {
  /// `orcamento_produtos.op_valor` é DECIMAL(10,2).
  static const double maxUnitValue = 99999999.99;

  /// Dígitos do valor unitário, incluindo os centavos (99.999.999,99).
  static const int maxUnitValueDigits = 10;

  /// `orcamentos.orc_total` é DECIMAL(15,2).
  static const double maxTotal = 9999999999999.99;

  static const String totalExceededMessage =
      'O valor total do orçamento ultrapassa o limite permitido. '
      'Revise as quantidades e os valores dos produtos.';

  static double clampUnitValue(double value) {
    if (value.isNaN || value <= 0) return 0;
    return value > maxUnitValue ? maxUnitValue : value;
  }

  static bool exceedsMaxTotal(double total) => total.isNaN || total > maxTotal;
}
