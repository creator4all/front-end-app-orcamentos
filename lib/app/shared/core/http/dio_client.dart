import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../config/api_config.dart';
import '../errors/failures.dart';

class DioClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout:
            const Duration(seconds: 30), // Aumentado de 10 para 30 segundos
        receiveTimeout:
            const Duration(seconds: 30), // Aumentado de 10 para 30 segundos
        sendTimeout: const Duration(seconds: 30), // Adicionado sendTimeout
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent':
              'App-Orcamentos-V1', // User-Agent específico para evitar OTP
        },
      ),
    );

    _dio.interceptors.add(_authInterceptor());
    _dio.interceptors.add(_loggingInterceptor());
    _dio.interceptors.add(_errorInterceptor());
  }

  Dio get dio => _dio;

  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          // Adicionar token de autenticação se disponível
          final token = await _secureStorage.read(key: 'auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          // Log error but continue without authentication
          // In production, you might want to report this to telemetry
          // For now, we silently continue without setting auth header
        }
        handler.next(options);
      },
    );
  }

  InterceptorsWrapper _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    );
  }

  InterceptorsWrapper _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        _handleDioError(error);
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
        return ServerFailure(
            'Erro de conexão. Verifique se a API está rodando em ${ApiConfig.baseUrl}');
      default:
        return ServerFailure('Erro desconhecido: ${error.message}');
    }
  }
}
