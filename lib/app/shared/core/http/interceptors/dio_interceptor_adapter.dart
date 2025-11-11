import 'package:dio/dio.dart';

import '../http_response.dart';
import 'http_interceptor.dart';

/// Adapter que converte interceptadores customizados em interceptadores do Dio
///
/// Permite usar a interface [HttpInterceptor] independente do Dio,
/// facilitando testes e desacoplamento da implementação.
class DioInterceptorAdapter extends Interceptor {
  final HttpInterceptor _interceptor;

  DioInterceptorAdapter(this._interceptor);

  /// Converte RequestOptions do Dio em HttpRequestInfo
  HttpRequestInfo _convertToRequestInfo(
    RequestOptions options, [
    int? statusCode,
  ]) {
    return HttpRequestInfo(
      method: options.method,
      url: '${options.baseUrl}${options.path}',
      data: options.data,
      headers: Map<String, dynamic>.from(options.headers),
      timeout: options.sendTimeout,
    );
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final requestInfo = _convertToRequestInfo(options);
      _interceptor.onRequest(requestInfo);
      super.onRequest(options, handler);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: e,
          message: 'Erro no interceptor onRequest: ${e.toString()}',
        ),
      );
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      final requestInfo = _convertToRequestInfo(
        response.requestOptions,
        response.statusCode,
      );

      final httpResponse = HttpResponse(
        body: response.data is Map<String, dynamic>
            ? response.data
            : {'data': response.data},
        headers: response.headers.map,
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        requestInfo: requestInfo,
      );

      _interceptor.onResponse(httpResponse);
      super.onResponse(response, handler);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: e,
          message: 'Erro no interceptor onResponse: ${e.toString()}',
        ),
      );
    }
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final requestInfo = _convertToRequestInfo(
        err.requestOptions,
        err.response?.statusCode,
      );

      final shouldRetry = await _interceptor.onError(
        err,
        requestInfo,
        err.response?.statusMessage ?? '',
        err.response?.data?.toString() ?? '',
      );

      if (shouldRetry) {
        // Retry a requisição
        try {
          final response = await Dio().fetch(err.requestOptions);
          handler.resolve(response);
        } catch (e) {
          handler.next(err);
        }
      } else {
        handler.next(err);
      }
    } catch (e) {
      handler.next(err);
    }
  }
}
