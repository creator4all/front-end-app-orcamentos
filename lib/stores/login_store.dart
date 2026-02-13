import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';

import '../controllers/login_controller.dart';
import '../logics/login_logic.dart';
import '../services/auth_service.dart';
import 'auth_store.dart';

part 'login_store.g.dart';

class LoginStore = _LoginStore with _$LoginStore;

abstract class _LoginStore with Store {
  final AuthStore _authStore;
  late final LoginController _loginController;

  _LoginStore(this._authStore) {
    final authService = Modular.get<AuthService>();
    final loginLogic = LoginLogic(authService);
    _loginController = LoginController(
      loginLogic: loginLogic,
      authStore: _authStore,
    );
  }

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @action
  void setLoading(bool loading) {
    isLoading = loading;
  }

  @action
  void setError(String? errorMessage) {
    error = errorMessage;
  }

  @action
  Future<bool> login(String email, String password) async {
    setLoading(true);
    setError(null);

    try {
      final success = await _loginController.login(email, password);

      setLoading(false);

      if (!success) {
        setError(_authStore.error);
      }

      return success;
    } catch (e) {
      setLoading(false);
      setError('Erro ao fazer login: ${e.toString()}');
      return false;
    }
  }

  @action
  Future<bool> tryAutoLogin() async {
    try {
      return await _loginController.tryAutoLogin();
    } catch (e) {
      return false;
    }
  }

  @action
  Future<void> logout() async {
    await _loginController.logout();
  }

  Map<String, dynamic> validateLoginInput(String email, String password) {
    return _loginController.validateLoginInput(email, password);
  }
}

