import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthService with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  final storage = const FlutterSecureStorage();

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Simulação de API para login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Em um cenário real, isso seria uma chamada de API
      // Simulando um atraso de rede
      await Future.delayed(const Duration(seconds: 1));

      // Simulando validação de credenciais
      if (email.isNotEmpty && password.isNotEmpty) {
        // Simulando resposta do servidor
        final userData = {
          'id': '1',
          'email': email,
          'name': 'Usuário Parceiro',
          'token': 'token_simulado_${DateTime.now().millisecondsSinceEpoch}',
        };

        _user = User.fromJson(userData);
        
        // Salvar token para persistência de login
        await storage.write(key: 'auth_token', value: _user!.token);
        await storage.write(key: 'user_data', value: jsonEncode(userData));
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Email ou senha inválidos';
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
        _user = User.fromJson(jsonDecode(userData));
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
      // Simulando um atraso de rede
      await Future.delayed(const Duration(seconds: 1));
      
      // Em um cenário real, isso enviaria um email de recuperação
      if (email.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Email inválido';
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
