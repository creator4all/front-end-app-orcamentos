/// Utilitário para validação de emails.
///
/// Centraliza a regex de validação para evitar duplicação no projeto.
class EmailValidator {
  static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  /// Valida se o email está no formato correto.
  static bool isValid(String email) => _emailRegex.hasMatch(email);

  /// Retorna mensagem de erro se inválido, null se válido.
  ///
  /// Pode ser usado diretamente como validator em TextFormField.
  static String? getError(String? email) {
    if (email == null || email.isEmpty) {
      return 'Por favor, digite seu e-mail';
    }
    if (!isValid(email)) {
      return 'Por favor, digite um e-mail válido';
    }
    return null;
  }
}
