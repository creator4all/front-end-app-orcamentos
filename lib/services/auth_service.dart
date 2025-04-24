import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../entities/user_entity.dart';

class AuthService with ChangeNotifier {
  UserEntity? _user;
  bool _isLoading = false;
  String? _error;
  final storage = const FlutterSecureStorage();

  UserEntity? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Set user data (called from controller)
  void setUser(UserEntity user) {
    _user = user;
    notifyListeners();
  }
  
  // Clear user data (called from controller)
  void clearUser() {
    _user = null;
    notifyListeners();
  }

  // Login method (now delegated to controller)
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

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
        _user = UserEntity.fromJson(responseData);
        
        // Salvar token para persistência de login
        await storage.write(key: 'auth_token', value: _user!.token);
        await storage.write(key: 'user_data', value: jsonEncode(responseData));
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = responseData['message'] ?? 'Falha na autenticação';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erro ao fazer login: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'user_data');
    _user = null;
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final token = await storage.read(key: 'auth_token');
    final userData = await storage.read(key: 'user_data');
    
    if (token != null && userData != null) {
      try {
        _user = UserEntity.fromJson(jsonDecode(userData));
        notifyListeners();
        return true;
      } catch (e) {
        await logout();
        return false;
      }
    }
    return false;
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

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
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = responseData['message'] ?? 'Falha ao resetar senha';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erro ao resetar senha: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
