import '../models/user_model.dart';

abstract class AuthDatasource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserModel> getCurrentUser({bool forceRefresh = false});

  Future<String?> getStoredToken();

  Future<bool> validateToken(String token);

  Future<void> requestPasswordReset(String email);
  Future<void> resendOtpCode(String email);

  Future<bool> verifyOtpCode(String email, String otpCode);

  Future<void> resetPassword(
    String email,
    String otpCode,
    String novaSenha,
    String confirmarSenha,
  );

  Future<UserModel> removeAvatar();
}
