import 'dart:convert';
import 'package:mobx/mobx.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../entities/user_entity.dart';
import 'auth_store.dart';
import 'package:http/http.dart' as http;

// Include generated file
part 'login_store.g.dart';

// This is the class used by rest of the codebase
class LoginStore = _LoginStore with _$LoginStore;

// The store class
abstract class _LoginStore with Store {
  final AuthStore _authStore;
  final storage = const FlutterSecureStorage();
  
  _LoginStore(this._authStore);
  
  @observable
  bool isLoading = false;
  
  @observable
  String? error;
  
  // Validate login input
  @action
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
  @action
  Future<bool> login(String email, String password) async {
    // Reset state
    isLoading = true;
    error = null;
    
    try {
      // Validate input
      final validation = validateLoginInput(email, password);
      if (!validation['isValid']) {
        error = validation['error'];
        isLoading = false;
        return false;
      }
      
      // Authenticate with API
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
        // Parse user data
        final user = UserEntity.fromJson(responseData);
        
        // Save user data and token
        await storage.write(key: 'auth_token', value: user.token);
        await storage.write(key: 'user_data', value: jsonEncode(user.toJson()));
        
        // Update auth store
        _authStore.setUser(user);
        
        isLoading = false;
        return true;
      } else {
        error = responseData['message'] ?? 'Falha na autenticação';
        isLoading = false;
        return false;
      }
    } catch (e) {
      error = 'Erro ao fazer login: ${e.toString()}';
      isLoading = false;
      return false;
    }
  }
  
  // Try auto login from stored credentials
  @action
  Future<bool> tryAutoLogin() async {
    try {
      final token = await storage.read(key: 'auth_token');
      final userData = await storage.read(key: 'user_data');
      
      if (token != null && userData != null) {
        final user = UserEntity.fromJson(jsonDecode(userData));
        
        if (user != null) {
          _authStore.setUser(user);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Logout user
  @action
  Future<void> logout() async {
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'user_data');
    _authStore.clearUser();
  }
}
