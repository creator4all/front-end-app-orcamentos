import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../../../config/api_config.dart';
import '../../../../../shared/core/constants/http_constants.dart';
import '../../../../../shared/core/errors/http_exceptions.dart';
import '../../../../../shared/core/http/app_http_client.dart';
import '../../../../../shared/core/http/http_request_config.dart';
import '../../../../../shared/core/utils/token_cache.dart';
import '../models/user_model.dart';
import 'auth_datasource.dart';

class AuthApiDatasource implements AuthDatasource {
  final AppHttpClient httpClient;
  final FlutterSecureStorage secureStorage;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  AuthApiDatasource({
    required this.httpClient,
    required this.secureStorage,
  });

  HttpRequestConfig get _defaultConfig => HttpRequestConfig(
        headers: {HttpHeaders.userAgent: HttpHeaders.userAgentValue},
      );

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await httpClient.post(
        ApiConfig.loginEndpoint,
        data: {
          'usr_email': email,
          'usr_password': password,
        },
        config: _defaultConfig,
      );

      final data = response.body;

      if (!data.containsKey('dados')) {
        throw Exception(
            'Resposta da API inválida: chave "dados" não encontrada');
      }

      final dadosResponse = data['dados'] as Map<String, dynamic>;

      if (dadosResponse.containsKey('token') &&
          dadosResponse['token'] != null) {
        final token = dadosResponse['token'].toString();

        await secureStorage.write(
          key: _tokenKey,
          value: token,
        );

        TokenCache.instance.setToken(token);
      } else {
        throw Exception('Token não retornado pela API de login');
      }

      final userModel = await getCurrentUser(forceRefresh: true);

      await secureStorage.write(
        key: _userKey,
        value: jsonEncode(userModel.toJson()),
      );

      return userModel;
    } on UnauthorizedException {
      rethrow;
    } on ForbiddenException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on InternalServerException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } on ConnectionException {
      rethrow;
    } catch (e) {
      throw Exception('Erro inesperado ao fazer login: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final token = await getStoredToken();

      if (token != null) {
        try {
          await httpClient.post(
            '/api/auth/logout',
            config: HttpRequestConfig(
              token: token,
              headers: {HttpHeaders.userAgent: HttpHeaders.userAgentValue},
            ),
          );
        } catch (_) {}
      }

      await secureStorage.delete(key: _tokenKey);
      await secureStorage.delete(key: _userKey);
      TokenCache.instance.clearToken();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  @override
  Future<UserModel> getCurrentUser({bool forceRefresh = false}) async {
    try {
      final token = await getStoredToken();

      if (token == null) {
        throw Exception('Token não encontrado. Faça login novamente.');
      }

      if (!forceRefresh) {
        final cachedUser = await secureStorage.read(key: _userKey);
        if (cachedUser != null) {
          try {
            final userJson = jsonDecode(cachedUser) as Map<String, dynamic>;
            return UserModel.fromJson(userJson);
          } catch (_) {}
        }
      }

      final response = await httpClient.get(
        '/api/perfil/me',
        config: HttpRequestConfig(
          token: token,
          headers: {HttpHeaders.userAgent: HttpHeaders.userAgentValue},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.body;
        final userData = data['dados'] as Map<String, dynamic>;

        final userModel = UserModel.fromJson(userData);

        await secureStorage.write(
          key: _userKey,
          value: jsonEncode(userModel.toJson()),
        );

        return userModel;
      } else {
        throw Exception('Falha ao obter dados do usuário');
      }
    } on UnauthorizedException {
      await secureStorage.delete(key: _tokenKey);
      await secureStorage.delete(key: _userKey);
      throw Exception('Sessão expirada. Faça login novamente.');
    } catch (e) {
      throw Exception('Erro inesperado ao obter usuário: $e');
    }
  }

  @override
  Future<String?> getStoredToken() async {
    try {
      return await secureStorage.read(key: _tokenKey);
    } catch (e) {
      throw Exception('Erro ao ler token: $e');
    }
  }

  @override
  Future<bool> validateToken(String token) async {
    try {
      final response = await httpClient.get(
        '/api/auth/validate',
        config: HttpRequestConfig(
          token: token,
          headers: {HttpHeaders.userAgent: HttpHeaders.userAgentValue},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.body;
        final dados = data['dados'] as Map<String, dynamic>?;
        return dados?['valido'] == true;
      }

      return false;
    } on UnauthorizedException {
      return false;
    } catch (e) {
      throw Exception('Erro inesperado ao validar token: $e');
    }
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      await httpClient.post(
        '/api/auth/forgot-password',
        data: {'usr_email': email},
        config: _defaultConfig,
      );
    } on NotFoundException {
      throw Exception('Usuário não encontrado com este email');
    } on BadRequestException catch (e) {
      throw Exception('Email inválido: ${e.message}');
    } on InternalServerException {
      throw Exception('Erro no servidor. Tente novamente mais tarde.');
    } on ConnectionException {
      throw Exception('Falha na conexão. Verifique sua internet.');
    } catch (e) {
      throw Exception('Erro ao enviar email de recuperação: $e');
    }
  }

  @override
  Future<void> resendOtpCode(String email) async {
    try {
      await httpClient.post(
        '/api/auth/forgot-password/resend',
        data: {'usr_email': email},
        config: _defaultConfig,
      );
    } on NotFoundException {
      throw Exception('Usuário não encontrado');
    } on TooManyRequestsException {
      throw Exception('Aguarde antes de solicitar um novo código');
    } on InternalServerException {
      throw Exception('Erro no servidor. Tente novamente mais tarde.');
    } on ConnectionException {
      throw Exception('Falha na conexão. Verifique sua internet.');
    } catch (e) {
      throw Exception('Erro ao reenviar código: $e');
    }
  }

  @override
  Future<bool> verifyOtpCode(String email, String otpCode) async {
    try {
      final response = await httpClient.post(
        '/api/auth/forgot-password/validate-otp',
        data: {
          'usr_email': email,
          'otp_code': otpCode,
        },
        config: _defaultConfig,
      );

      final data = response.body;
      final dados = data['dados'] as Map<String, dynamic>?;
      return dados?['valido'] == true;
    } on UnauthorizedException {
      throw Exception('Código OTP inválido');
    } on BadRequestException {
      throw Exception('Código OTP inválido ou expirado');
    } on NotFoundException {
      throw Exception('Solicitação de recuperação não encontrada');
    } on InternalServerException {
      throw Exception('Erro no servidor. Tente novamente mais tarde.');
    } on ConnectionException {
      throw Exception('Falha na conexão. Verifique sua internet.');
    } catch (e) {
      throw Exception('Erro ao verificar código: $e');
    }
  }

  @override
  Future<void> resetPassword(
    String email,
    String otpCode,
    String novaSenha,
    String confirmarSenha,
  ) async {
    try {
      await httpClient.post(
        '/api/auth/reset-password',
        data: {
          'usr_email': email,
          'otp_code': otpCode,
          'nova_senha': novaSenha,
          'confirmar_senha': confirmarSenha,
        },
        config: _defaultConfig,
      );
    } on UnauthorizedException {
      throw Exception('Código OTP inválido ou expirado');
    } on BadRequestException catch (e) {
      throw Exception('Erro ao redefinir senha: ${e.message}');
    } on NotFoundException {
      throw Exception('Solicitação de recuperação não encontrada');
    } on InternalServerException {
      throw Exception('Erro no servidor. Tente novamente mais tarde.');
    } on ConnectionException {
      throw Exception('Falha na conexão. Verifique sua internet.');
    } catch (e) {
      throw Exception('Erro ao redefinir senha: $e');
    }
  }

  @override
  Future<UserModel> removeAvatar() async {
    try {
      final response = await httpClient.delete(
        '/api/perfil/me/avatar',
        config: _defaultConfig,
      );

      if (response.statusCode == 200) {
        final data = response.body;
        final userData = data['dados'] as Map<String, dynamic>;

        final userModel = UserModel.fromJson(userData);

        await secureStorage.write(
          key: _userKey,
          value: jsonEncode(userModel.toJson()),
        );

        return userModel;
      } else {
        throw Exception('Falha ao remover avatar');
      }
    } catch (e) {
      throw Exception('Erro ao remover avatar: $e');
    }
  }
}
