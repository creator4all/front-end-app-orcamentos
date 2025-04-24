import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../entities/user_entity.dart';

class LoginLogic {
  // Authenticate user with API
  Future<Map<String, dynamic>> authenticateUser(String email, String password) async {
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

  // Validate login input
  Map<String, dynamic> validateLoginInput(String email, String password) {
    if (email.isEmpty) {
      return {
        'isValid': false,
        'error': 'O email é obrigatório',
      };
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return {
        'isValid': false,
        'error': 'Email inválido',
      };
    }

    if (password.isEmpty) {
      return {
        'isValid': false,
        'error': 'A senha é obrigatória',
      };
    }

    return {
      'isValid': true,
    };
  }

  // Parse user data from API response
  UserEntity? parseUserData(Map<String, dynamic> data) {
    try {
      return UserEntity.fromJson(data);
    } catch (e) {
      return null;
    }
  }
}
