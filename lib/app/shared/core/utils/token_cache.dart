/// Cache síncrono para armazenar o token de autenticação em memória
///
/// Como o SecureStorage é assíncrono, precisamos de um cache em memória
/// para acessar o token de forma síncrona nos interceptors HTTP.
///
/// Este cache é atualizado quando:
/// - Usuário faz login
/// - Token é refreshed
/// - Usuário faz logout (limpa o cache)
class TokenCache {
  static TokenCache? _instance;
  String? _token;

  TokenCache._();

  /// Singleton instance
  static TokenCache get instance {
    _instance ??= TokenCache._();
    return _instance!;
  }

  /// Salva o token no cache
  void setToken(String token) {
    _token = token;
  }

  /// Retorna o token do cache (pode ser null)
  String? getToken() {
    return _token;
  }

  /// Verifica se há token válido
  bool hasToken() {
    return _token != null && _token!.isNotEmpty;
  }

  /// Limpa o token do cache
  void clearToken() {
    _token = null;
  }

  /// Retorna token ou string vazia
  String getTokenOrEmpty() {
    return _token ?? '';
  }
}
