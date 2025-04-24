import 'package:mobx/mobx.dart';
import '../controllers/login_controller.dart';
import '../services/auth_service.dart';
import '../logics/login_logic.dart';
import 'auth_store.dart';

// Include generated file
part 'login_store.g.dart';

// This is the class used by rest of the codebase
class LoginStore = _LoginStore with _$LoginStore;

// The store class
abstract class _LoginStore with Store {
  final AuthStore _authStore;
  late final LoginController _loginController;
  
  _LoginStore(this._authStore) {
    // Initialize controller with proper dependencies
    final authService = AuthService();
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
  
  // Process login
  @action
  Future<bool> login(String email, String password) async {
    // Reset state
    setLoading(true);
    setError(null);
    
    try {
      // Use controller to process login
      final success = await _loginController.login(email, password);
      
      // Update loading state
      setLoading(false);
      
      // Get error from auth store if login failed
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
  
  // Try auto login from stored credentials
  @action
  Future<bool> tryAutoLogin() async {
    try {
      return await _loginController.tryAutoLogin();
    } catch (e) {
      return false;
    }
  }
  
  // Logout user
  @action
  Future<void> logout() async {
    await _loginController.logout();
  }
  
  // Validate login input
  Map<String, dynamic> validateLoginInput(String email, String password) {
    return _loginController.validateLoginInput(email, password);
  }
}
