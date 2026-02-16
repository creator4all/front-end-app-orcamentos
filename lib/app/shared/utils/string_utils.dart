library;

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  if (text.length == 1) return text.toUpperCase();
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

extension StringCapitalizationExtension on String {
  String capitalizeFirst() => capitalizeFirstLetter(this);
}

String removeAccents(String text) {
  const accents = 'ÀÁÂÃÄÅàáâãäåÈÉÊËèéêëÌÍÎÏìíîïÒÓÔÕÖØòóôõöøÙÚÛÜùúûüÇçÑñÝýÿ';
  const noAccents = 'AAAAAAaaaaaaEEEEeeeeIIIIiiiiOOOOOOooooooUUUUuuuuCcNnYyy';

  String result = text;
  for (int i = 0; i < accents.length; i++) {
    result = result.replaceAll(accents[i], noAccents[i]);
  }
  return result;
}

int compareIgnoringAccents(String a, String b) {
  return removeAccents(a.toLowerCase())
      .compareTo(removeAccents(b.toLowerCase()));
}
