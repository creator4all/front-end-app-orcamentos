import '../models/user_model.dart';

/// Interface abstrata do DataSource de autenticação
/// Define os contratos para acesso a dados externos (API, cache, etc)
abstract class AuthDatasource {
  /// Realiza login via API e retorna UserModel
  Future<UserModel> login({
    required String email,
    required String password,
  });

  /// Realiza logout e limpa dados armazenados
  Future<void> logout();

  /// Obtém usuário do cache local ou API
  /// [forceRefresh] se true, ignora cache e busca direto da API
  Future<UserModel> getCurrentUser({bool forceRefresh = false});

  /// Obtém o token armazenado localmente
  Future<String?> getStoredToken();

  /// Valida o token com a API
  Future<bool> validateToken(String token);
}
