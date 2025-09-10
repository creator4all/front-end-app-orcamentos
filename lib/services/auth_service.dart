import 'package:dio/dio.dart';

import '../config/api_config.dart';

class AuthService {
  final Dio _dio;

  AuthService({Dio? dio}) : _dio = dio ?? Dio();

  // Authenticate user with API
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.signInEndpoint,
        data: {
          'email': email,
          'password': password,
        },
        options: Options(headers: ApiConfig.headers),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'error': response.data?['message'] ?? 'Falha na autenticação',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de conexão: ${e.toString()}',
      };
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      final response = await _dio.post(
        ApiConfig.resetPasswordEndpoint,
        data: {
          'email': email,
        },
        options: Options(headers: ApiConfig.headers),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'error': response.data?['message'] ?? 'Falha ao resetar senha',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro ao resetar senha: ${e.toString()}',
      };
    }
  }
}
