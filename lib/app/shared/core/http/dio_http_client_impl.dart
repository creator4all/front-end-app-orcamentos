import 'dart:io';

import 'package:dio/dio.dart';

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

/// Implementação do AppHttpClient usando Dio
///
/// Esta classe é a implementação concreta que usa o Dio para fazer
/// requisições HTTP, integra todos os interceptors e converte
/// respostas do Dio para nossos modelos customizados.
class DioHttpClientImpl implements AppHttpClient {
  final HttpClientConfig config;
  late final Dio _dio;

  DioHttpClientImpl(this.config) {
    _initializeDio();
  }

  /// Inicializa o Dio com configurações e interceptors
  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout ?? config.timeout,
        receiveTimeout: config.receiveTimeout ?? config.timeout,
        sendTimeout: config.timeout,
        validateStatus: (status) => true, // Não lançar erro por status code
        followRedirects: config.followRedirects,
        maxRedirects: config.maxRedirects,
      ),
    );

    // Adiciona headers padrão
    if (config.defaultHeaders != null) {
      _dio.options.headers.addAll(config.defaultHeaders!);
    }

    // Adiciona interceptors customizados
    if (config.interceptors != null) {
      for (final interceptor in config.interceptors!) {
        _dio.interceptors.add(DioInterceptorAdapter(interceptor));
      }
    }

    // Adiciona logger se habilitado
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

  /// Método central para executar requisições
  Future<HttpResponse> _executeRequest(
    String method,
    String url,
    dynamic data,
    HttpRequestConfig? config,
  ) async {
    // Valida conexão com internet antes de fazer requisição
    await NetworkUtils.validateInternet();

    // Monta options da requisição
    final options = _buildOptions(method, config);

    // Monta URL completa
    final fullUrl = _buildUrl(url, config);

    try {
      // Executa a requisição
      final response = await _dio.request(
        fullUrl,
        data: data,
        options: options,
        queryParameters: config?.queryParameters,
        onSendProgress: config?.sendProgress,
        onReceiveProgress: config?.receiveProgress,
      );

      // Valida resposta antes de converter
      _validateResponse(response);

      // Converte response do Dio para HttpResponse
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
    // Valida conexão com internet
    await NetworkUtils.validateInternet();

    // Monta options
    final options = _buildOptions('GET', config);
    options.responseType = ResponseType.bytes;

    // Timeout maior para downloads
    options.receiveTimeout = config?.timeout ?? const Duration(minutes: 5);

    // Monta URL completa
    final fullUrl = _buildUrl(url, config);

    // Cria CancelToken do Dio
    CancelToken? dioCancel;
    if (cancelToken != null) {
      dioCancel = CancelToken();
      cancelToken.subscribe(() => dioCancel!.cancel('Download cancelado'));
    }

    try {
      final response = await _dio.download(
        fullUrl,
        savePath,
        cancelToken: dioCancel,
        onReceiveProgress: config?.receiveProgress,
        options: options,
        queryParameters: config?.queryParameters,
      );

      return response.toDownloadHttpResponse(filePath: savePath);
    } on DioException catch (e) {
      // Tratamento específico para erros de download
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

  /// Constrói Options do Dio baseado na configuração
  Options _buildOptions(String method, HttpRequestConfig? config) {
    final headers = <String, dynamic>{};

    // Adiciona headers customizados
    if (config?.headers != null) {
      headers.addAll(config!.headers!);
    }

    // Adiciona token de autenticação
    final token =
        config?.token ?? config?.token ?? this.config.getToken?.call();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    // Define Content-Type
    headers['Content-Type'] = config?.contentType ?? 'application/json';

    return Options(
      method: method,
      headers: headers,
      responseType: _mapResponseType(config?.responseType),
      receiveTimeout: config?.timeout,
      sendTimeout: config?.timeout,
      validateStatus: (status) => true, // Tratamos status manualmente
    );
  }

  /// Constrói URL completa
  String _buildUrl(String url, HttpRequestConfig? config) {
    // Se URL já é completa (começa com http), usa ela
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // Usa baseUrl da config ou global
    final baseUrl = config?.baseUrl ?? this.config.baseUrl;

    // Remove barra no final da baseUrl e início da url se necessário
    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanUrl = url.startsWith('/') ? url : '/$url';

    return '$cleanBase$cleanUrl';
  }

  /// Mapeia HttpResponseType para ResponseType do Dio
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

  /// Valida a resposta e lança exceção se houver erro
  void _validateResponse(Response response) {
    final statusCode = response.statusCode;

    // Se status code indica erro, lança exceção apropriada
    if (statusCode != null && (statusCode < 200 || statusCode >= 300)) {
      throw HttpExceptionFactory.fromStatusCode(
        statusCode: statusCode,
        message: _extractErrorMessage(response),
        endpoint: response.requestOptions.path,
        data: response.data,
      );
    }

    // Verifica se o backend retornou status "erro" no body
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

  /// Extrai mensagem de erro da resposta
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

  /// Converte DioException em nossas exceções customizadas
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
      default:
        // Se for erro de internet do sistema operacional
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
