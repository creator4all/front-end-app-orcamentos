/// Utilitários para manipulação de strings
library;

/// Capitaliza a primeira letra de uma string
///
/// Converte a primeira letra para maiúscula e o restante para minúscula
///
/// Exemplos:
/// ```dart
/// capitalizeFirstLetter('educação infantil') // 'Educação infantil'
/// capitalizeFirstLetter('TABLET') // 'Tablet'
/// capitalizeFirstLetter('lousa digital') // 'Lousa digital'
/// capitalizeFirstLetter('') // ''
/// ```
String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  if (text.length == 1) return text.toUpperCase();
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

/// Extension method para facilitar o uso
extension StringCapitalizationExtension on String {
  /// Capitaliza a primeira letra desta string
  String capitalizeFirst() => capitalizeFirstLetter(this);
}
