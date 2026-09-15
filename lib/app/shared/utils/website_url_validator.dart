/// Prepara e valida a URL do site de uma empresa.
///
/// O webservice valida esse campo com `filter_var(FILTER_VALIDATE_URL)`, que
/// exige esquema explícito: `www.empresa.com.br` é recusado com 422. Como o
/// usuário raramente digita `https://`, o app completa o esquema antes de
/// enviar.
class WebsiteUrlValidator {
  static const _allowedSchemes = {'http', 'https'};

  /// Devolve a URL pronta para envio, ou `null` quando o campo está vazio.
  static String? normalize(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final hasScheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://').hasMatch(trimmed);
    return hasScheme ? trimmed : 'https://$trimmed';
  }

  static bool isValid(String value) {
    final normalized = normalize(value);
    if (normalized == null) return true;

    if (normalized.contains(' ')) return false;

    final uri = Uri.tryParse(normalized);
    if (uri == null) return false;

    return _allowedSchemes.contains(uri.scheme.toLowerCase()) &&
        uri.host.isNotEmpty;
  }

  /// Retorna a mensagem de erro, ou `null` se a URL for aceitável.
  static String? getError(String value) {
    if (isValid(value)) return null;
    return 'Informe uma URL válida, por exemplo https://www.suaempresa.com.br';
  }
}
