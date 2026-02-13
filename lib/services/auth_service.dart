import '../app/shared/core/http/app_http_client.dart';
import '../config/api_config.dart';

class AuthService {
  final AppHttpClient _client;

  AuthService({required AppHttpClient client}) : _client = client;

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await _client.post(
        ApiConfig.signInEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.isSuccess) {
        return {
          'success': true,
          'data': response.body,
        };
      } else {
        return {
          'success': false,
          'error': response.body['message'] ?? 'Falha na autenticação',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de conexão: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      final response = await _client.post(
        ApiConfig.resetPasswordEndpoint,
        data: {
          'email': email,
        },
      );

      if (response.isSuccess) {
        return {
          'success': true,
          'data': response.body,
        };
      } else {
        return {
          'success': false,
          'error': response.body['message'] ?? 'Falha ao resetar senha',
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