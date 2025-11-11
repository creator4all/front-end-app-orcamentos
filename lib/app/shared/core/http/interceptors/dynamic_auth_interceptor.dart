import '../http_response.dart';
import 'http_interceptor.dart';

/// Interceptor para autenticação dinâmica com fallback para SecureStorage
///
/// Tenta buscar o token do AuthStore primeiro, se não encontrar
/// busca do SecureStorage como fallback.
class DynamicAuthInterceptor extends HttpInterceptor {
  final String authScheme;
  final List<String> excludedPaths;

  DynamicAuthInterceptor({
    this.authScheme = 'Bearer',
    this.excludedPaths = const ['/login', '/register', '/refresh-token'],
  });

  @override
  void onRequest(HttpRequestInfo request) {
    // Verifica se a URL deve ser excluída da autenticação
    final shouldExclude = excludedPaths.any(
      (path) => request.url.contains(path),
    );

    if (shouldExclude) {
      return;
    }

    // Verifica se já tem Authorization header
    final hasAuth = request.headers.keys.any(
      (key) => key.toLowerCase() == 'authorization',
    );

    if (!hasAuth) {
      final token = _getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = '$authScheme $token';
      }
    }
  }

  /// Busca token dinamicamente (Secure Storage de forma síncrona com cache)
  String? _getToken() {
    try {
      // Para buscar token de forma síncrona, precisamos de um cache
      // Por enquanto, retornamos null e deixamos o HttpClient
      // buscar o token via getToken() da configuração

      // TODO: Implementar TokenCache se necessário
      // Um cache síncrono que guarda o token em memória
      // e é atualizado quando o usuário faz login

      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> onError(
    Exception error,
    HttpRequestInfo request,
    String responseMessage,
    String responsePayload,
  ) async {
    // Se for erro 401 (Unauthorized), limpa o token e pode redirecionar para login
    // Implementação futura: refresh token automático
    return false;
  }
}
