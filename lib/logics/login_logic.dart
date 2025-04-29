import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../entities/user_entity.dart';
import '../services/auth_service.dart';

class LoginLogic {
  final AuthService _authService;
  final storage = const FlutterSecureStorage();
  
  LoginLogic(this._authService);
  
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
  
  // Process login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Validate input
      final validation = validateLoginInput(email, password);
      if (!validation['isValid']) {
        return {
          'success': false,
          'error': validation['error'],
        };
      }
      
      // Call auth service
      final result = await _authService.signIn(email, password);
      
      if (result['success']) {
        // Parse user data
        final responseData = result['data'];
        final user = UserEntity.fromJson(responseData);
        
        // Create user data with normalized role
        final userData = user.toJson();
        userData['role'] = user.normalizedRole; // Use normalized role
        
        // Save user data and token
        await storage.write(key: 'auth_token', value: user.token);
        await storage.write(key: 'user_data', value: jsonEncode(userData));
        
        return {
          'success': true,
          'user': user,
        };
      } else {
        return {
          'success': false,
          'error': result['error'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro ao processar login: ${e.toString()}',
      };
    }
  }
  
  // Try auto login from stored credentials
  Future<Map<String, dynamic>> tryAutoLogin() async {
    try {
      final token = await storage.read(key: 'auth_token');
      final userData = await storage.read(key: 'user_data');
      
      if (token != null && userData != null) {
        try {
          final user = UserEntity.fromJson(jsonDecode(userData));
          
          return {
            'success': true,
            'user': user,
          };
        } catch (e) {
          await logout();
          return {
            'success': false,
            'error': 'Dados de usuário inválidos',
          };
        }
      }
      return {
        'success': false,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro ao tentar login automático: ${e.toString()}',
      };
    }
  }
  
  // Logout user
  Future<void> logout() async {
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'user_data');
  }
}
