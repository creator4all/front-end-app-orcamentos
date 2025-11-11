import '../http_response.dart';
import 'http_interceptor.dart';

/// Interceptor para adicionar autenticação automática nas requisições
///
/// Adiciona automaticamente o token de autenticação em todas as requisições
/// que não possuem um token customizado.
///
/// Exemplo de uso:
/// ```dart
/// HttpClientConfig(
///   getToken: () => authService.currentToken,
///   interceptors: [AuthInterceptor()],
/// )
/// ```
class AuthInterceptor extends HttpInterceptor {
  final String Function()? getToken;
  final String authScheme;
  final List<String> excludedPaths;

  AuthInterceptor({
    this.getToken,
    this.authScheme = 'Bearer',
    this.excludedPaths = const [],
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

    if (!hasAuth && getToken != null) {
      final token = getToken!();
      if (token.isNotEmpty) {
        request.headers['Authorization'] = '$authScheme $token';
      }
    }
  }

  @override
  Future<bool> onError(
    Exception error,
    HttpRequestInfo request,
    String responseMessage,
    String responsePayload,
  ) async {
    // Se for erro 401 (Unauthorized), pode implementar lógica de refresh token aqui
    // Retornar true fará retry automático da requisição
    return false;
  }
}
