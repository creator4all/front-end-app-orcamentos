import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../errors/failures.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(_loggingInterceptor());
    _dio.interceptors.add(_errorInterceptor());
  }

  Dio get dio => _dio;

  InterceptorsWrapper _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        print('REQUEST[${options.method}] => PATH: ${options.path}');
        print('DATA: ${options.data}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        print('DATA: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) {
        print(
            'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
        print('MESSAGE: ${error.message}');
        handler.next(error);
      },
    );
  }

  InterceptorsWrapper _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        final failure = _handleDioError(error);
        // You can handle global errors here
        handler.next(error);
      },
    );
  }

  ServerFailure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ServerFailure('Timeout de conexão');
      case DioExceptionType.badResponse:
        return ServerFailure('Erro do servidor: ${error.response?.statusCode}');
      case DioExceptionType.cancel:
        return const ServerFailure('Requisição cancelada');
      case DioExceptionType.connectionError:
        return const ServerFailure('Erro de conexão');
      default:
        return const ServerFailure('Erro desconhecido');
    }
  }
}
