import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ApiService {
  final Dio _dio;

  ApiService({Dio? dio}) : _dio = dio ?? Dio();

  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint, {String? token}) async {
    try {
      final options = Options(
        headers: token != null
            ? ApiConfig.headersWithToken(token)
            : ApiConfig.headers,
      );

      final response = await _dio.get(
        endpoint,
        options: options,
      );

      return _processResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de conexão: ${e.toString()}',
      };
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data,
      {String? token}) async {
    try {
      final options = Options(
        headers: token != null
            ? ApiConfig.headersWithToken(token)
            : ApiConfig.headers,
      );

      final response = await _dio.post(
        endpoint,
        data: data,
        options: options,
      );

      return _processResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de conexão: ${e.toString()}',
      };
    }
  }

  // Generic PUT request
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data,
      {String? token}) async {
    try {
      final options = Options(
        headers: token != null
            ? ApiConfig.headersWithToken(token)
            : ApiConfig.headers,
      );

      final response = await _dio.put(
        endpoint,
        data: data,
        options: options,
      );

      return _processResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de conexão: ${e.toString()}',
      };
    }
  }

  // Generic DELETE request
  Future<Map<String, dynamic>> delete(String endpoint, {String? token}) async {
    try {
      final options = Options(
        headers: token != null
            ? ApiConfig.headersWithToken(token)
            : ApiConfig.headers,
      );

      final response = await _dio.delete(
        endpoint,
        options: options,
      );

      return _processResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de conexão: ${e.toString()}',
      };
    }
  }

  // Process Dio response
  Map<String, dynamic> _processResponse(Response response) {
    try {
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'error': response.data?['message'] ?? 'Erro na requisição',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro ao processar resposta: ${e.toString()}',
        'statusCode': response.statusCode,
      };
    }
  }
}
