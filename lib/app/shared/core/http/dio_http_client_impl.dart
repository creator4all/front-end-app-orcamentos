import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../errors/app_error.dart';
import '../errors/http_exceptions.dart';
import '../utils/network_utils.dart';
import 'app_http_client.dart';
import 'extensions/dio_response_extension.dart';
import 'http_client_config.dart';
import 'http_request_config.dart';
import 'http_response.dart';
import 'interceptors/dio_interceptor_adapter.dart';
import 'interceptors/logger_interceptor.dart';

class DioHttpClientImpl implements AppHttpClient {
  final HttpClientConfig config;
  late final Dio _dio;
  final Map<Duration?, Dio> _dioCache = {};

  DioHttpClientImpl(this.config) {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout ?? config.timeout,
        receiveTimeout: config.receiveTimeout ?? config.timeout,
        sendTimeout: config.timeout,
        validateStatus: (status) => true,
        followRedirects: config.followRedirects,
        maxRedirects: config.maxRedirects,
      ),
    );

    if (config.defaultHeaders != null) {
      _dio.options.headers.addAll(config.defaultHeaders!);
    }

    if (config.interceptors != null) {
      for (final interceptor in config.interceptors!) {
        _dio.interceptors.add(DioInterceptorAdapter(interceptor));
      }
    }

    if (config.enableLogger) {
      _dio.interceptors.add(DioInterceptorAdapter(LoggerInterceptor()));
    }
  }

  @override
  Future<HttpResponse> get(String url, {HttpRequestConfig? config}) {
    return _executeRequest('GET', url, null, config);
  }

  @override
  Future<HttpResponse> post(String url, {data, HttpRequestConfig? config}) {
    return _executeRequest('POST', url, data, config);
  }

  @override
  Future<HttpResponse> put(String url, {data, HttpRequestConfig? config}) {
    return _executeRequest('PUT', url, data, config);
  }

  @override
  Future<HttpResponse> patch(String url, {data, HttpRequestConfig? config}) {
    return _executeRequest('PATCH', url, data, config);
  }

  @override
  Future<HttpResponse> delete(String url, {data, HttpRequestConfig? config}) {
    return _executeRequest('DELETE', url, data, config);
  }

  @override
  Future<HttpResponse> head(String url, {HttpRequestConfig? config}) {
    return _executeRequest('HEAD', url, null, config);
  }

  @override
  Future<HttpResponse> options(String url, {HttpRequestConfig? config}) {
    return _executeRequest('OPTIONS', url, null, config);
  }

  Future<HttpResponse> _executeRequest(
    String method,
    String url,
    dynamic data,
    HttpRequestConfig? config,
  ) async {
    await NetworkUtils.validateInternet();

    final options = _buildOptions(method, config);

    final fullUrl = _buildUrl(url, config);

    try {
      final response = await _dio.request(
        fullUrl,
        data: data,
        options: options,
        queryParameters: config?.queryParameters,
        onSendProgress: config?.sendProgress,
        onReceiveProgress: config?.receiveProgress,
      );

      await _validateResponse(response);

      return response.toHttpResponse();
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppUnknownError(
        message: 'Erro desconhecido na requisição: ${e.toString()}',
        data: e,
        stackTrace: StackTrace.current,
      );
    }
  }

  @override
  Future<DownloadHttpResponse> download(
    String url,
    String savePath, {
    CancelDownload? cancelToken,
    HttpRequestConfig? config,
  }) async {
    await NetworkUtils.validateInternet();

    final options = _buildOptions('GET', config);
    options.responseType = ResponseType.bytes;

    options.receiveTimeout = config?.timeout ?? const Duration(minutes: 5);

    final fullUrl = _buildUrl(url, config);

    CancelToken? dioCancel;
    if (cancelToken != null) {
      dioCancel = CancelToken();
      cancelToken.subscribe(() => dioCancel!.cancel('Download cancelado'));
    }

    _debugDownloadLog('Starting download request [$fullUrl] -> $savePath');

    try {
      final response = await _dioFor(config).download(
        fullUrl,
        savePath,
        cancelToken: dioCancel,
        onReceiveProgress: _wrapDownloadProgress(
          'download',
          fullUrl,
          savePath: savePath,
          callback: config?.receiveProgress,
        ),
        options: options,
        queryParameters: config?.queryParameters,
      );

      final statusCode = response.statusCode;
      if (statusCode != null && (statusCode < 200 || statusCode >= 300)) {
        if (statusCode == 401) {
          await _notifyUnauthorized();
        }

        throw HttpExceptionFactory.fromStatusCode(
          statusCode: statusCode,
          message: response.statusMessage ?? 'Erro ao fazer download',
          endpoint: response.requestOptions.path,
          data: response.data,
        );
      }

      _debugDownloadLog(
        'Completed download request [$fullUrl] -> $savePath (status=${response.statusCode})',
      );
      return response.toDownloadHttpResponse(filePath: savePath);
    } on DioException catch (e) {
      _debugDownloadLog(
        'Download request failed [$fullUrl] -> $savePath: type=${e.type}, message=${e.message}',
      );
      if (e.error is FileSystemException) {
        final fileError = e.error as FileSystemException;
        if (fileError.osError?.message.contains('No space left') ?? false) {
          throw const AppStorageError(
            'Espaço insuficiente para fazer download',
          );
        }
      }

      if (e.type == DioExceptionType.cancel) {
        throw const CancelledException(message: 'Download cancelado');
      }

      throw _handleDioException(e);
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppUnknownError(
        message: 'Erro ao fazer download: ${e.toString()}',
        data: e,
        stackTrace: StackTrace.current,
      );
    }
  }

  @override
  Future<List<int>> getBytes(String url, {HttpRequestConfig? config}) async {
    await NetworkUtils.validateInternet();

    final options = _buildOptions('GET', config);
    options.responseType = ResponseType.bytes;
    options.receiveTimeout = config?.timeout ?? const Duration(minutes: 5);

    final fullUrl = _buildUrl(url, config);

    _debugDownloadLog('Starting bytes request [$fullUrl]');

    try {
      final response = await _dioFor(config).get<List<int>>(
        fullUrl,
        options: options,
        queryParameters: config?.queryParameters,
        onReceiveProgress: _wrapDownloadProgress(
          'getBytes',
          fullUrl,
          callback: config?.receiveProgress,
        ),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        _debugDownloadLog(
          'Completed bytes request [$fullUrl] (status=${response.statusCode}, bytes=${response.data?.length ?? 0})',
        );
        return response.data ?? [];
      }

      if (response.statusCode == 401) {
        await _notifyUnauthorized();
      }

      throw HttpException(
        message: 'Falha ao baixar arquivo',
        statusCode: response.statusCode,
        endpoint: fullUrl,
      );
    } on DioException catch (e) {
      _debugDownloadLog(
        'Bytes request failed [$fullUrl]: type=${e.type}, message=${e.message}',
      );
      throw _handleDioException(e);
    } catch (e) {
      if (e is AppError) rethrow;
      _debugDownloadLog('Bytes request threw [$fullUrl]: $e');
      throw AppUnknownError(
        message: 'Erro ao baixar bytes: ${e.toString()}',
        data: e,
        stackTrace: StackTrace.current,
      );
    }
  }

  @override
  Future<HttpResponse> uploadFile(
    String url, {
    required String filePath,
    required String fileField,
    HttpRequestConfig? config,
  }) async {
    final extension = filePath.split('.').last.toLowerCase();
    final mimeSubtype = extension == 'png' ? 'png' : 'jpeg';

    final formData = FormData.fromMap({
      fileField: await MultipartFile.fromFile(
        filePath,
        contentType: DioMediaType('image', mimeSubtype),
      ),
    });

    final uploadConfig = (config ?? HttpRequestConfig()).copyWith(
      contentType: 'multipart/form-data',
    );

    return _executeRequest('POST', url, formData, uploadConfig);
  }

  Options _buildOptions(String method, HttpRequestConfig? config) {
    final headers = <String, dynamic>{};

    if (config?.headers != null) {
      headers.addAll(config!.headers!);
    }

    final token =
        config?.token ?? config?.token ?? this.config.getToken?.call();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final contentType = config?.contentType;
    if (contentType != 'multipart/form-data') {
      headers['Content-Type'] = contentType ?? 'application/json';
    }

    return Options(
      method: method,
      headers: headers,
      responseType: _mapResponseType(config?.responseType),
      receiveTimeout: config?.timeout,
      sendTimeout: config?.timeout,
      validateStatus: (status) => true,
    );
  }

  Dio _dioFor(HttpRequestConfig? config) {
    if (config?.connectTimeout == null) return _dio;

    final timeout = config!.connectTimeout;
    return _dioCache.putIfAbsent(timeout, () {
      final clone = Dio(_dio.options.copyWith(connectTimeout: timeout));
      clone.interceptors.addAll(_dio.interceptors);
      return clone;
    });
  }

  void _debugDownloadLog(String message) {
    if (!kDebugMode) return;
    debugPrint('[HTTP DOWNLOAD] $message');
  }

  void Function(int received, int total)? _wrapDownloadProgress(
    String operation,
    String url, {
    String? savePath,
    void Function(int received, int total)? callback,
  }) {
    if (!kDebugMode) return callback;

    bool firstByteLogged = false;
    int? lastBucket;

    return (received, total) {
      if (!firstByteLogged && received > 0) {
        firstByteLogged = true;
        _debugDownloadLog(
          '$operation: first byte received${savePath != null ? ' -> $savePath' : ''} [$url]',
        );
      }

      if (total > 0) {
        final percent = (received / total) * 100;
        final bucket = (percent / 10).floor();
        if (lastBucket != bucket || received == total) {
          lastBucket = bucket;
          _debugDownloadLog(
            '$operation: ${percent.toStringAsFixed(1)}% ($received/$total)${savePath != null ? ' -> $savePath' : ''} [$url]',
          );
        }
      } else if (received > 0 && received % (512 * 1024) == 0) {
        _debugDownloadLog(
          '$operation: received $received bytes (total unknown)${savePath != null ? ' -> $savePath' : ''} [$url]',
        );
      }

      callback?.call(received, total);
    };
  }

  String _buildUrl(String url, HttpRequestConfig? config) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    final baseUrl = config?.baseUrl ?? this.config.baseUrl;

    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanUrl = url.startsWith('/') ? url : '/$url';

    return '$cleanBase$cleanUrl';
  }

  ResponseType _mapResponseType(HttpResponseType? type) {
    if (type == null) return ResponseType.json;

    switch (type) {
      case HttpResponseType.json:
        return ResponseType.json;
      case HttpResponseType.plain:
        return ResponseType.plain;
      case HttpResponseType.bytes:
        return ResponseType.bytes;
      case HttpResponseType.stream:
        return ResponseType.stream;
    }
  }

  Future<void> _validateResponse(Response response) async {
    final statusCode = response.statusCode;

    if (statusCode != null && (statusCode < 200 || statusCode >= 300)) {
      if (statusCode == 401) {
        await _notifyUnauthorized();
      }

      throw HttpExceptionFactory.fromStatusCode(
        statusCode: statusCode,
        message: _extractErrorMessage(response),
        endpoint: response.requestOptions.path,
        data: response.data,
      );
    }

    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;

      if (data['status'] == 'erro' || data['status'] == 'error') {
        final message =
            data['mensagem'] ?? data['message'] ?? 'Erro na requisição';
        throw HttpException(
          message: message,
          statusCode: statusCode,
          endpoint: response.requestOptions.path,
          data: data,
        );
      }
    }
  }

  Future<void> _notifyUnauthorized() async {
    try {
      await config.onUnauthorized?.call();
    } catch (_) {}
  }

  String _extractErrorMessage(Response response) {
    try {
      if (response.data == null) {
        return response.statusMessage ?? 'Erro na requisição';
      }

      if (response.data is String) {
        return response.data;
      }

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        return data['mensagem'] ??
            data['message'] ??
            data['erro'] ??
            data['error'] ??
            response.statusMessage ??
            'Erro na requisição';
      }

      return response.statusMessage ?? 'Erro na requisição';
    } catch (e) {
      return 'Erro na requisição';
    }
  }

  Exception _handleDioException(DioException error) {
    final endpoint = error.requestOptions.path;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'Tempo de requisição esgotado',
          endpoint: endpoint,
        );

      case DioExceptionType.connectionError:
        return ConnectionException(
          message: 'Erro de conexão. Verifique sua internet',
          endpoint: endpoint,
          data: error.error,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 500;
        return HttpExceptionFactory.fromStatusCode(
          statusCode: statusCode,
          message: _extractErrorMessage(error.response!),
          endpoint: endpoint,
          data: error.response?.data,
        );

      case DioExceptionType.cancel:
        return CancelledException(
          message: 'Requisição cancelada',
          endpoint: endpoint,
        );

      case DioExceptionType.badCertificate:
        return ConnectionException(
          message: 'Certificado SSL inválido',
          endpoint: endpoint,
          data: error.error,
        );

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return ConnectionException(
            message: 'Sem conexão com a internet',
            endpoint: endpoint,
            data: error.error,
          );
        }

        return HttpException(
          message: error.message ?? 'Erro desconhecido',
          statusCode: error.response?.statusCode,
          endpoint: endpoint,
          data: error.error,
        );
    }
  }
}
