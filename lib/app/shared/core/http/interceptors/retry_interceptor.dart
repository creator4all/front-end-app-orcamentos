import 'package:dio/dio.dart';

import '../http_response.dart';
import 'http_interceptor.dart';

/// Interceptor para retry automático de requisições que falham
///
/// Tenta reexecutar requisições que falharam devido a problemas
/// temporários (timeout, conexão perdida, etc.)
///
/// Exemplo de uso:
/// ```dart
/// HttpClientConfig(
///   interceptors: [
///     RetryInterceptor(
///       maxRetries: 3,
///       retryDelays: [
///         Duration(seconds: 1),
///         Duration(seconds: 2),
///         Duration(seconds: 3),
///       ],
///     ),
///   ],
/// )
/// ```
class RetryInterceptor extends HttpInterceptor {
  final int maxRetries;
  final List<Duration> retryDelays;
  final List<int> retryableStatusCodes;

  /// Mapa para rastrear tentativas por requisição
  final Map<String, int> _requestAttempts = {};

  RetryInterceptor({
    this.maxRetries = 3,
    List<Duration>? retryDelays,
    this.retryableStatusCodes = const [408, 429, 500, 502, 503, 504],
  }) : retryDelays = retryDelays ??
            List.generate(
              maxRetries,
              (index) => Duration(seconds: (index + 1)),
            );

  String _getRequestKey(HttpRequestInfo request) {
    return '${request.method}:${request.url}';
  }

  @override
  Future<bool> onError(
    Exception error,
    HttpRequestInfo request,
    String responseMessage,
    String responsePayload,
  ) async {
    final requestKey = _getRequestKey(request);
    final currentAttempts = _requestAttempts[requestKey] ?? 0;

    // Se excedeu o número máximo de tentativas, não retry
    if (currentAttempts >= maxRetries) {
      _requestAttempts.remove(requestKey);
      return false;
    }

    // Verifica se é um erro que pode ser retried
    bool shouldRetry = false;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          shouldRetry = true;
          break;

        case DioExceptionType.badResponse:
          // Retry apenas para status codes específicos
          final statusCode = error.response?.statusCode;
          if (statusCode != null && retryableStatusCodes.contains(statusCode)) {
            shouldRetry = true;
          }
          break;

        default:
          shouldRetry = false;
      }
    }

    if (shouldRetry) {
      // Incrementa contador de tentativas
      _requestAttempts[requestKey] = currentAttempts + 1;

      // Aguarda antes de fazer retry
      final delayIndex = currentAttempts < retryDelays.length
          ? currentAttempts
          : retryDelays.length - 1;
      await Future.delayed(retryDelays[delayIndex]);

      return true; // Retry a requisição
    }

    _requestAttempts.remove(requestKey);
    return false;
  }

  @override
  void onResponse(HttpResponseBase response) {
    // Limpa contador de tentativas em caso de sucesso
    if (response.requestInfo != null) {
      final requestKey = _getRequestKey(response.requestInfo!);
      _requestAttempts.remove(requestKey);
    }
  }
}
