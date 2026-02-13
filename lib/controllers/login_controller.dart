import 'package:flutter_modular/flutter_modular.dart';

import '../entities/user_entity.dart';
import '../logics/login_logic.dart';
import '../services/auth_service.dart';
import '../stores/auth_store.dart';

class LoginController {
  final LoginLogic _loginLogic;
  final AuthStore _authStore;

  LoginController({LoginLogic? loginLogic, required AuthStore authStore})
      : _loginLogic = loginLogic ?? LoginLogic(Modular.get<AuthService>()),
        _authStore = authStore;

  Future<bool> login(String email, String password) async {
    try {
      final result = await _loginLogic.login(email, password);

      if (result['success']) {
        final user = result['user'] as UserEntity;
        _authStore.setUser(user);
        return true;
      } else {
        _authStore.setError(result['error']);
        return false;
      }
    } catch (e) {
      _authStore.setError('Erro inesperado: ${e.toString()}');
      return false;
    }
  }

  Future<bool> tryAutoLogin() async {
    try {
      final result = await _loginLogic.tryAutoLogin();

      if (result['success']) {
        final user = result['user'] as UserEntity;
        _authStore.setUser(user);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _loginLogic.logout();
    _authStore.clearUser();
  }

  Map<String, dynamic> validateLoginInput(String email, String password) {
    return _loginLogic.validateLoginInput(email, password);
  }
}

