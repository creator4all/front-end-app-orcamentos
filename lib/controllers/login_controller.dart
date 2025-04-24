import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../entities/user_entity.dart';
import '../logics/login_logic.dart';
import '../services/auth_service.dart';

class LoginController with ChangeNotifier {
  final LoginLogic _loginLogic = LoginLogic();
  final AuthService _authService;
  final storage = const FlutterSecureStorage();
  
  bool _isLoading = false;
  String? _error;
  
  LoginController(this._authService);
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Process login
  Future<bool> login(String email, String password) async {
    // Reset state
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Validate input
      final validation = _loginLogic.validateLoginInput(email, password);
      if (!validation['isValid']) {
        _error = validation['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Authenticate with API
      final result = await _loginLogic.authenticateUser(email, password);
      
      if (result['success']) {
        // Parse user data
        final userData = result['data'];
        final user = _loginLogic.parseUserData(userData);
        
        if (user != null) {
          // Save user data and token
          await storage.write(key: 'auth_token', value: user.token);
          await storage.write(key: 'user_data', value: jsonEncode(user.toJson()));
          
          // Update auth service
          _authService.setUser(user);
          
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = 'Erro ao processar dados do usuário';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _error = result['error'];
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
  
  // Try auto login from stored credentials
  Future<bool> tryAutoLogin() async {
    try {
      final token = await storage.read(key: 'auth_token');
      final userData = await storage.read(key: 'user_data');
      
      if (token != null && userData != null) {
        final user = _loginLogic.parseUserData(jsonDecode(userData));
        
        if (user != null) {
          _authService.setUser(user);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Logout user
  Future<void> logout() async {
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'user_data');
    _authService.clearUser();
  }
}
