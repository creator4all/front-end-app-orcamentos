import "package:mobx/mobx.dart";
import "../entities/user_entity.dart";

// Include generated file
part "auth_store.g.dart";

// This is the class used by rest of the codebase
class AuthStore = _AuthStore with _$AuthStore;

// The store class
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
  bool get isManager => user?.role == "manager";
  
  @computed
  bool get isSeller => user?.role == "seller";
  
  @computed
  bool get isAdmin => user?.role == "admin";

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
    // Clear user data
    clearUser();
  }
}
