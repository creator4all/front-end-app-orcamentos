import 'dart:convert';

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
    try {
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
        if (data is! Map<String, dynamic>) {
          throw Exception(
              'Resposta da API inválida: esperado Map<String, dynamic>, recebido ${data.runtimeType}');
        }

        if (!data.containsKey('dados')) {
          throw Exception(
              'Resposta da API inválida: chave "dados" não encontrada. Chaves disponíveis: ${data.keys.toList()}');
        }

        final dadosValue = data['dados'];
        if (dadosValue is! Map<String, dynamic>) {
          throw Exception(
              'Resposta da API inválida: "dados" deve ser Map<String, dynamic>, recebido ${dadosValue.runtimeType}');
        }

        final dadosResponse = dadosValue;

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
          value: jsonEncode(userDto.toJson()),
        );

        return userDto;
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors with user-friendly messages
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        switch (statusCode) {
          case 401:
            throw Exception(
                'Credenciais inválidas. Verifique seu email e senha.');
          case 403:
            throw Exception('Acesso negado. Conta pode estar desativada.');
          case 404:
            throw Exception(
                'Serviço não encontrado. Tente novamente mais tarde.');
          case 500:
            throw Exception(
                'Erro interno do servidor. Tente novamente mais tarde.');
          default:
            throw Exception(
                'Erro no servidor (código $statusCode). Tente novamente.');
        }
      } else {
        // Network or other connection errors
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            throw Exception(
                'Timeout de conexão. Verifique sua internet e tente novamente.');
          case DioExceptionType.connectionError:
            throw Exception('Erro de conexão. Verifique sua internet.');
          default:
            throw Exception('Erro de rede. Tente novamente mais tarde.');
        }
      }
    } catch (e) {
      // Handle any other unexpected errors
      throw Exception('Erro inesperado durante o login. Tente novamente.');
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
    try {
      final userData = await secureStorage.read(key: 'user_data');
      if (userData == null || userData.isEmpty) {
        return null;
      }

      final decodedMap = jsonDecode(userData) as Map<String, dynamic>;
      return UserDto.fromJson(decodedMap);
    } catch (e) {
      // Clear invalid storage data if JSON parsing fails
      await secureStorage.delete(key: 'user_data');
      return null;
    }
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
