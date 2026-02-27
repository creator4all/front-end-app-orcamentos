import 'package:mobx/mobx.dart';

import '../entities/user_entity.dart';

part 'auth_store.g.dart';

class AuthStore = _AuthStore with _$AuthStore;

abstract class _AuthStore with Store {
  @observable
  UserEntity? user;

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @computed
  bool get isAuthenticated => user != null;

  @computed
  bool get isManager {
    final role = user?.role.toLowerCase();
    return role == 'gerente' || role == 'manager';
  }

  @computed
  bool get isSeller {
    final role = user?.role.toLowerCase();
    return role == 'vendedor' || role == 'seller';
  }

  @computed
  bool get isAdmin {
    final role = user?.role.toLowerCase();
    return role == 'administrador' || role == 'admin';
  }

  @action
  void setUser(UserEntity newUser) {
    user = newUser;
    error = null;
  }

  @action
  void clearUser() {
    user = null;
  }

  @action
  void setLoading(bool loading) {
    isLoading = loading;
  }

  @action
  void setError(String? errorMessage) {
    error = errorMessage;
  }

  @action
  void clearError() {
    error = null;
  }

  @action
  Future<void> logout() async {
    clearUser();
  }

  @action
  Future<bool> deleteAccount(String confirmation) async {
    setLoading(true);
    clearError();

    try {
      if (confirmation.toLowerCase() != 'confirmar') {
        setError(
            'Texto de confirmação incorreto. Digite "confirmar" para excluir sua conta.');
        setLoading(false);
        return false;
      }

      await Future.delayed(const Duration(seconds: 1));

      await logout();

      setLoading(false);
      return true;
    } catch (e) {
      setError('Erro ao excluir conta: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }
}
