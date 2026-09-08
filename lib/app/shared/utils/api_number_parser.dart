/// Conversão tolerante de campos numéricos recebidos da API.
///
/// Colunas `DECIMAL` do backend são serializadas como string (`"1.00000000"`),
/// enquanto colunas inteiras chegam como número JSON. Um cast direto
/// (`as int?` / `as num?`) lança `TypeError` no primeiro formato, então todo
/// campo numérico de payload deve ser lido por aqui.
class ApiNumberParser {
  ApiNumberParser._();

  /// Converte [value] em `int`, retornando [fallback] quando não for numérico.
  static int toInt(dynamic value, {int fallback = 0}) =>
      toIntOrNull(value) ?? fallback;

  /// Converte [value] em `int`, ou `null` quando ausente/não numérico.
  static int? toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final normalized = value.trim();
      return int.tryParse(normalized) ?? double.tryParse(normalized)?.toInt();
    }
    return null;
  }

  /// Converte [value] em `double`, retornando [fallback] quando não for numérico.
  static double toDouble(dynamic value, {double fallback = 0}) =>
      toDoubleOrNull(value) ?? fallback;

  /// Converte [value] em `double`, ou `null` quando ausente/não numérico.
  static double? toDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }
}
