import 'package:dio/dio.dart';

import '../http_response.dart';

/// Extension para converter RequestOptions do Dio em HttpRequestInfo
extension DioRequestOptionsExtension on RequestOptions {
  /// Converte RequestOptions em HttpRequestInfo
  ///
  /// [statusCode] - Código de status opcional (usado em responses)
  HttpRequestInfo toHttpRequestInfo([int? statusCode]) {
    return HttpRequestInfo(
      method: method,
      url: uri.toString(),
      data: data,
      headers: Map<String, dynamic>.from(headers),
      timeout: sendTimeout,
    );
  }
}
