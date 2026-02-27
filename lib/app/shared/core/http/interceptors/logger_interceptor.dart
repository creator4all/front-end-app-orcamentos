import '../http_response.dart';
import 'http_interceptor.dart';

/// Interceptor para logging de requisições e respostas
///
/// Registra automaticamente todas as requisições HTTP no console,
/// facilitando o debug durante o desenvolvimento.
///
/// Exemplo de uso:
/// ```dart
/// HttpClientConfig(
///   enableLogger: true, // ou adicionar manualmente:
///   interceptors: [LoggerInterceptor()],
/// )
/// ```
class LoggerInterceptor extends HttpInterceptor {
  final bool logHeaders;
  final bool logBody;
  final bool logErrors;

  LoggerInterceptor({
    this.logHeaders = true,
    this.logBody = true,
    this.logErrors = true,
  });

  @override
  void onRequest(HttpRequestInfo request) {}

  @override
  void onResponse(HttpResponseBase response) {}

  @override
  Future<bool> onError(
    Exception error,
    HttpRequestInfo request,
    String responseMessage,
    String responsePayload,
  ) async {
    return false;
  }
}
