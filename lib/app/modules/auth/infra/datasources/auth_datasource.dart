import '../dtos/user_dto.dart';

abstract class AuthDatasource {
  Future<UserDto> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserDto?> getCurrentUser();

  Future<bool> isLoggedIn();

  Future<String?> getToken();
}
