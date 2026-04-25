library;

class DocumentValidators {
  static String normalizeDocument(String document) {
    return document.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static bool isValidCPF(String cpf) {
    cpf = normalizeDocument(cpf);

    if (cpf.length != 11) return false;

    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return false;

    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int firstDigit = (sum * 10) % 11;
    if (firstDigit == 10) firstDigit = 0;

    if (int.parse(cpf[9]) != firstDigit) return false;

    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    int secondDigit = (sum * 10) % 11;
    if (secondDigit == 10) secondDigit = 0;

    return int.parse(cpf[10]) == secondDigit;
  }

  static bool isValidCNPJ(String cnpj) {
    cnpj = normalizeDocument(cnpj);

    if (cnpj.length != 14) return false;

    if (RegExp(r'^(\d)\1{13}$').hasMatch(cnpj)) return false;

    const firstWeights = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += int.parse(cnpj[i]) * firstWeights[i];
    }
    int firstDigit = sum % 11;
    firstDigit = firstDigit < 2 ? 0 : 11 - firstDigit;

    if (int.parse(cnpj[12]) != firstDigit) return false;

    const secondWeights = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    sum = 0;
    for (int i = 0; i < 13; i++) {
      sum += int.parse(cnpj[i]) * secondWeights[i];
    }
    int secondDigit = sum % 11;
    secondDigit = secondDigit < 2 ? 0 : 11 - secondDigit;

    return int.parse(cnpj[13]) == secondDigit;
  }

  static bool isValidDocument(String document) {
    final cleanDoc = normalizeDocument(document);

    if (cleanDoc.length == 11) {
      return isValidCPF(cleanDoc);
    } else if (cleanDoc.length == 14) {
      return isValidCNPJ(cleanDoc);
    }

    return false;
  }

  static String? getDocumentError(String document) {
    final cleanDoc = normalizeDocument(document);

    if (cleanDoc.isEmpty) {
      return 'Por favor, informe o CPF ou CNPJ.';
    }

    if (cleanDoc.length != 11 && cleanDoc.length != 14) {
      return 'CPF deve ter 11 dígitos e CNPJ deve ter 14 dígitos.';
    }

    if (cleanDoc.length == 11) {
      if (!isValidCPF(cleanDoc)) {
        return 'O CPF informado não é válido. Por favor, verifique os números digitados.';
      }
    }

    if (cleanDoc.length == 14) {
      if (!isValidCNPJ(cleanDoc)) {
        return 'O CNPJ informado não é válido. Por favor, verifique os números digitados.';
      }
    }

    return null;
  }

  static String formatDocument(String document) {
    final cleanDoc = normalizeDocument(document);

    if (cleanDoc.length == 11) {
      return '${cleanDoc.substring(0, 3)}.${cleanDoc.substring(3, 6)}.${cleanDoc.substring(6, 9)}-${cleanDoc.substring(9)}';
    }

    if (cleanDoc.length == 14) {
      return '${cleanDoc.substring(0, 2)}.${cleanDoc.substring(2, 5)}.${cleanDoc.substring(5, 8)}/${cleanDoc.substring(8, 12)}-${cleanDoc.substring(12)}';
    }

    return cleanDoc;
  }
}
