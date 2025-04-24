import '../entities/user_entity.dart';
import '../logics/login_logic.dart';
import '../services/auth_service.dart';
import '../stores/auth_store.dart';

class LoginController {
  final LoginLogic _loginLogic;
  final AuthStore _authStore;
  
  LoginController({LoginLogic? loginLogic, required AuthStore authStore}) 
      : _loginLogic = loginLogic ?? LoginLogic(AuthService()),
        _authStore = authStore;
  
  // Process login
  Future<bool> login(String email, String password) async {
    try {
      // Call login logic
      final result = await _loginLogic.login(email, password);
      
      if (result['success']) {
        // Update auth store with user data
        final user = result['user'] as UserEntity;
        _authStore.setUser(user);
        return true;
      } else {
        // Update error in auth store
        _authStore.setError(result['error']);
        return false;
      }
    } catch (e) {
      // Handle unexpected errors
      _authStore.setError('Erro inesperado: ${e.toString()}');
      return false;
    }
  }
  
  // Try auto login from stored credentials
  Future<bool> tryAutoLogin() async {
    try {
      final result = await _loginLogic.tryAutoLogin();
      
      if (result['success']) {
        // Update auth store with user data
        final user = result['user'] as UserEntity;
        _authStore.setUser(user);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Logout user
  Future<void> logout() async {
    await _loginLogic.logout();
    _authStore.clearUser();
  }
  
  // Validate login input
  Map<String, dynamic> validateLoginInput(String email, String password) {
    return _loginLogic.validateLoginInput(email, password);
  }
}
