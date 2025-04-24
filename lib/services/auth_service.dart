import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../entities/user_entity.dart';

class AuthService {
  // Authenticate user with API
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.signInEndpoint),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(ApiConfig.requestTimeout);

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'error': responseData['message'] ?? 'Falha na autenticação',
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
      final response = await http.post(
        Uri.parse(ApiConfig.resetPasswordEndpoint),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'email': email,
        }),
      ).timeout(ApiConfig.requestTimeout);

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'error': responseData['message'] ?? 'Falha ao resetar senha',
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
