import 'package:flutter/foundation.dart';

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
  void onRequest(HttpRequestInfo request) {
    if (kDebugMode) {
      debugPrint('┌───────────────────────────────────────────────────────');
      debugPrint('│ 📤 REQUEST');
      debugPrint('├───────────────────────────────────────────────────────');
      debugPrint('│ Method: ${request.method}');
      debugPrint('│ URL: ${request.url}');

      if (logHeaders && request.headers.isNotEmpty) {
        debugPrint('├─ Headers:');
        request.headers.forEach((key, value) {
          // Oculta tokens sensíveis nos logs
          final displayValue = key.toLowerCase() == 'authorization'
              ? '***TOKEN***'
              : value.toString();
          debugPrint('│   $key: $displayValue');
        });
      }

      if (logBody && request.data != null) {
        debugPrint('├─ Body:');
        debugPrint('│   ${request.data}');
      }

      if (request.timeout != null) {
        debugPrint('├─ Timeout: ${request.timeout?.inSeconds}s');
      }

      debugPrint('└───────────────────────────────────────────────────────');
    }
  }

  @override
  void onResponse(HttpResponseBase response) {
    if (kDebugMode) {
      debugPrint('┌───────────────────────────────────────────────────────');
      debugPrint('│ 📥 RESPONSE');
      debugPrint('├───────────────────────────────────────────────────────');
      debugPrint('│ Status Code: ${response.statusCode}');
      debugPrint('│ Status Message: ${response.statusMessage ?? 'N/A'}');

      if (response.requestInfo != null) {
        debugPrint('│ URL: ${response.requestInfo!.url}');
      }

      if (logHeaders && response.headers.isNotEmpty) {
        debugPrint('├─ Headers:');
        response.headers.forEach((key, value) {
          debugPrint('│   $key: ${value.join(', ')}');
        });
      }

      if (logBody && response is HttpResponse) {
        debugPrint('├─ Body:');
        final bodyStr = response.body.toString();
        if (bodyStr.length > 500) {
          debugPrint('│   ${bodyStr.substring(0, 500)}... (truncated)');
        } else {
          debugPrint('│   $bodyStr');
        }
      }

      if (response is DownloadHttpResponse) {
        debugPrint('├─ Download:');
        debugPrint('│   Size: ${response.sizeInMB.toStringAsFixed(2)} MB');
        debugPrint('│   Path: ${response.filePath ?? 'N/A'}');
      }

      debugPrint('└───────────────────────────────────────────────────────');
    }
  }

  @override
  Future<bool> onError(
    Exception error,
    HttpRequestInfo request,
    String responseMessage,
    String responsePayload,
  ) async {
    if (kDebugMode && logErrors) {
      debugPrint('┌───────────────────────────────────────────────────────');
      debugPrint('│ ❌ ERROR');
      debugPrint('├───────────────────────────────────────────────────────');
      debugPrint('│ Method: ${request.method}');
      debugPrint('│ URL: ${request.url}');
      debugPrint('├─ Error:');
      debugPrint('│   ${error.toString()}');

      if (responseMessage.isNotEmpty) {
        debugPrint('├─ Response Message:');
        debugPrint('│   $responseMessage');
      }

      if (responsePayload.isNotEmpty) {
        debugPrint('├─ Response Payload:');
        final payload = responsePayload.length > 500
            ? '${responsePayload.substring(0, 500)}... (truncated)'
            : responsePayload;
        debugPrint('│   $payload');
      }

      debugPrint('└───────────────────────────────────────────────────────');
    }

    return false; // Não retry
  }
}
