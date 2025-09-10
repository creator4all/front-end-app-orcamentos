import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../../config/api_config.dart';
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
      ApiConfig.loginEndpoint,
      options: Options(
        headers: ApiConfig.headers,
      ),
      data: {
        'usr_email': email,
        'usr_password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data;

      // Verificar se a resposta tem a estrutura esperada
      if (data['dados'] == null) {
        throw Exception('Resposta da API inválida');
      }

      final dadosResponse = data['dados'];

      // Save token
      if (dadosResponse['token'] != null) {
        await secureStorage.write(
          key: 'auth_token',
          value: dadosResponse['token'],
        );
      }

      // Como a API não retorna dados do usuário, vamos criar um usuário básico
      final userDto = UserDto(
        id: '1', // ID fictício, idealmente viria da API
        name: 'Usuário Logado',
        email: email,
      );

      await secureStorage.write(
        key: 'user_data',
        value: userDto.toJson().toString(),
      );

      return userDto;
    } else {
      throw Exception('Login failed: ${response.statusMessage}');
    }
  }

  @override
  Future<void> logout() async {
    await secureStorage.delete(key: 'auth_token');
    await secureStorage.delete(key: 'user_data');
    await secureStorage.delete(key: 'refresh_token');
  }

  @override
  Future<UserDto?> getCurrentUser() async {
    final userData = await secureStorage.read(key: 'user_data');
    if (userData != null) {
      // In a real implementation, you'd parse the JSON properly
      // For now, return null if no user data
      return null;
    }
    return null;
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await secureStorage.read(key: 'auth_token');
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> getToken() async {
    final token = await secureStorage.read(key: 'auth_token');
    return token;
  }
}
