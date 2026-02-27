/// Utilitários para manipulação de datas
library;

/// Faz parse seguro de datas vindas da API
///
/// Suporta:
/// - null (retorna null)
/// - DateTime (retorna como está)
/// - String ISO 8601 (faz parse)
///
/// Retorna null se o parse falhar, evitando exceptions
DateTime? parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}
