import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../shared/core/constants/api_constants.dart';
import '../../infra/datasources/auth_datasource.dart';
import '../../infra/dtos/user_dto.dart';

class AuthApiDatasource implements AuthDatasource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  AuthApiDatasource({
    required this.dio,
    required this.secureStorage,
  });

  @override
  Future<UserDto> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      ApiConstants.loginEndpoint,
      data: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data;

      // Save token
      if (data['token'] != null) {
        await secureStorage.write(
          key: ApiConstants.tokenKey,
          value: data['token'],
        );
      }

      // Save user data
      final userDto = UserDto.fromJson(data['user']);
      await secureStorage.write(
        key: ApiConstants.userKey,
        value: userDto.toJson().toString(),
      );

      return userDto;
    } else {
      throw Exception('Login failed');
    }
  }

  @override
  Future<void> logout() async {
    await secureStorage.delete(key: ApiConstants.tokenKey);
    await secureStorage.delete(key: ApiConstants.userKey);
    await secureStorage.delete(key: ApiConstants.refreshTokenKey);
  }

  @override
  Future<UserDto?> getCurrentUser() async {
    final userData = await secureStorage.read(key: ApiConstants.userKey);
    if (userData != null) {
      // In a real implementation, you'd parse the JSON properly
      // For now, return null if no user data
      return null;
    }
    return null;
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await secureStorage.read(key: ApiConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }
}
