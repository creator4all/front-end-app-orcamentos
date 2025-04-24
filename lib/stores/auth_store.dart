import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobx/mobx.dart';
import '../config/api_config.dart';
import '../entities/user_entity.dart';
import 'package:http/http.dart' as http;

// Include generated file
part 'auth_store.g.dart';

// This is the class used by rest of the codebase
class AuthStore = _AuthStore with _$AuthStore;

// The store class
abstract class _AuthStore with Store {
  final storage = const FlutterSecureStorage();

  @observable
  UserEntity? user;

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @computed
  bool get isAuthenticated => user != null;

  @action
  void setUser(UserEntity newUser) {
    user = newUser;
  }

  @action
  void clearUser() {
    user = null;
  }

  @action
  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;

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
        user = UserEntity.fromJson(responseData);
        
        // Salvar token para persistência de login
        await storage.write(key: 'auth_token', value: user!.token);
        await storage.write(key: 'user_data', value: jsonEncode(responseData));
        
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

  @action
  Future<void> logout() async {
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'user_data');
    user = null;
  }

  @action
  Future<bool> tryAutoLogin() async {
    final token = await storage.read(key: 'auth_token');
    final userData = await storage.read(key: 'user_data');
    
    if (token != null && userData != null) {
      try {
        user = UserEntity.fromJson(jsonDecode(userData));
        return true;
      } catch (e) {
        await logout();
        return false;
      }
    }
    return false;
  }

  @action
  Future<bool> resetPassword(String email) async {
    isLoading = true;
    error = null;

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
        isLoading = false;
        return true;
      } else {
        error = responseData['message'] ?? 'Falha ao resetar senha';
        isLoading = false;
        return false;
      }
    } catch (e) {
      error = 'Erro ao resetar senha: ${e.toString()}';
      isLoading = false;
      return false;
    }
  }
}
