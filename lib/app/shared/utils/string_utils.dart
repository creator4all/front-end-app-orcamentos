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

/// Remove acentos de uma string para comparação alfabética
///
/// Exemplos:
/// ```dart
/// removeAccents('Águas da Prata') // 'Aguas da Prata'
/// removeAccents('São Paulo') // 'Sao Paulo'
/// ```
String removeAccents(String text) {
  const accents = 'ÀÁÂÃÄÅàáâãäåÈÉÊËèéêëÌÍÎÏìíîïÒÓÔÕÖØòóôõöøÙÚÛÜùúûüÇçÑñÝýÿ';
  const noAccents = 'AAAAAAaaaaaaEEEEeeeeIIIIiiiiOOOOOOooooooUUUUuuuuCcNnYyy';

  String result = text;
  for (int i = 0; i < accents.length; i++) {
    result = result.replaceAll(accents[i], noAccents[i]);
  }
  return result;
}

/// Compara duas strings ignorando acentos (ordenação alfabética correta)
///
/// Útil para ordenar listas onde "Águas" deve vir antes de "Barra"
int compareIgnoringAccents(String a, String b) {
  return removeAccents(a.toLowerCase())
      .compareTo(removeAccents(b.toLowerCase()));
}
