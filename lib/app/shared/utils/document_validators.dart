/// Utilitários para validação de documentos brasileiros (CPF/CNPJ)
///
/// Implementa validação com algoritmo módulo 11 conforme especificação
/// da Receita Federal.
library;

/// Classe utilitária para validação de CPF e CNPJ
class DocumentValidators {
  /// Valida CPF (11 dígitos) usando algoritmo módulo 11
  ///
  /// Retorna `true` se o CPF for válido, `false` caso contrário.
  ///
  /// Exemplo:
  /// ```dart
  /// DocumentValidators.isValidCPF('12345678909'); // true
  /// DocumentValidators.isValidCPF('11111111111'); // false
  /// ```
  static bool isValidCPF(String cpf) {
    // Remove caracteres não numéricos
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');

    // Verifica se tem 11 dígitos
    if (cpf.length != 11) return false;

    // Verifica se todos os dígitos são iguais (ex: 111.111.111-11)
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return false;

    // Calcula primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int firstDigit = (sum * 10) % 11;
    if (firstDigit == 10) firstDigit = 0;

    // Verifica primeiro dígito
    if (int.parse(cpf[9]) != firstDigit) return false;

    // Calcula segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    int secondDigit = (sum * 10) % 11;
    if (secondDigit == 10) secondDigit = 0;

    // Verifica segundo dígito
    return int.parse(cpf[10]) == secondDigit;
  }

  /// Valida CNPJ (14 dígitos) usando algoritmo módulo 11
  ///
  /// Retorna `true` se o CNPJ for válido, `false` caso contrário.
  ///
  /// Exemplo:
  /// ```dart
  /// DocumentValidators.isValidCNPJ('11222333000181'); // true
  /// DocumentValidators.isValidCNPJ('00000000000000'); // false
  /// ```
  static bool isValidCNPJ(String cnpj) {
    // Remove caracteres não numéricos
    cnpj = cnpj.replaceAll(RegExp(r'[^0-9]'), '');

    // Verifica se tem 14 dígitos
    if (cnpj.length != 14) return false;

    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1{13}$').hasMatch(cnpj)) return false;

    // Pesos para cálculo do primeiro dígito
    const firstWeights = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += int.parse(cnpj[i]) * firstWeights[i];
    }
    int firstDigit = sum % 11;
    firstDigit = firstDigit < 2 ? 0 : 11 - firstDigit;

    // Verifica primeiro dígito
    if (int.parse(cnpj[12]) != firstDigit) return false;

    // Pesos para cálculo do segundo dígito
    const secondWeights = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    sum = 0;
    for (int i = 0; i < 13; i++) {
      sum += int.parse(cnpj[i]) * secondWeights[i];
    }
    int secondDigit = sum % 11;
    secondDigit = secondDigit < 2 ? 0 : 11 - secondDigit;

    // Verifica segundo dígito
    return int.parse(cnpj[13]) == secondDigit;
  }

  /// Valida CPF ou CNPJ baseado no tamanho
  ///
  /// - 11 dígitos: valida como CPF
  /// - 14 dígitos: valida como CNPJ
  /// - Outros tamanhos: retorna `false`
  static bool isValidDocument(String document) {
    final cleanDoc = document.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanDoc.length == 11) {
      return isValidCPF(cleanDoc);
    } else if (cleanDoc.length == 14) {
      return isValidCNPJ(cleanDoc);
    }

    return false;
  }

  /// Retorna mensagem de erro amigável ou null se documento for válido
  ///
  /// Use este método para obter mensagens prontas para exibir ao usuário.
  ///
  /// Exemplo:
  /// ```dart
  /// final error = DocumentValidators.getDocumentError('123');
  /// // 'CPF deve ter 11 dígitos e CNPJ deve ter 14 dígitos.'
  /// ```
  static String? getDocumentError(String document) {
    final cleanDoc = document.replaceAll(RegExp(r'[^0-9]'), '');

    // Verifica tamanho
    if (cleanDoc.isEmpty) {
      return 'Por favor, informe o CPF ou CNPJ.';
    }

    if (cleanDoc.length != 11 && cleanDoc.length != 14) {
      return 'CPF deve ter 11 dígitos e CNPJ deve ter 14 dígitos.';
    }

    // Valida como CPF
    if (cleanDoc.length == 11) {
      if (!isValidCPF(cleanDoc)) {
        return 'O CPF informado não é válido. Por favor, verifique os números digitados.';
      }
    }

    // Valida como CNPJ
    if (cleanDoc.length == 14) {
      if (!isValidCNPJ(cleanDoc)) {
        return 'O CNPJ informado não é válido. Por favor, verifique os números digitados.';
      }
    }

    return null; // Documento válido
  }
}
