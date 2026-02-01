import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../../../config/api_config.dart';
import '../../../../../shared/core/errors/http_exceptions.dart';
import '../../../../../shared/core/http/app_http_client.dart';
import '../../../../../shared/core/http/http_request_config.dart';
import '../../../../../shared/core/utils/token_cache.dart';
import '../models/user_model.dart';
import 'auth_datasource.dart';

/// Implementação do DataSource de autenticação
/// Responsável por fazer chamadas HTTP e gerenciar armazenamento seguro
class AuthApiDatasource implements AuthDatasource {
  final AppHttpClient httpClient;
  final Dio dio; // Mantido temporariamente para getCurrentUser e outros métodos
  final FlutterSecureStorage secureStorage;

  // Keys para storage
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  AuthApiDatasource({
    required this.httpClient,
    required this.dio,
    required this.secureStorage,
  });

  /// Configuração padrão para requisições HTTP
  /// User-Agent é obrigatório para evitar OTP em mobile
  HttpRequestConfig get _defaultConfig => HttpRequestConfig(
        headers: {'User-Agent': 'App-Orcamentos-V1'},
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

        // TokenCache permite acesso síncrono ao token nos interceptors
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
      throw Exception('Credenciais inválidas. Verifique seu email e senha.');
    } on ForbiddenException {
      throw Exception('Acesso negado. Conta pode estar desativada.');
    } on NotFoundException {
      throw Exception('Serviço não encontrado. Tente novamente mais tarde.');
    } on InternalServerException {
      throw Exception('Erro interno do servidor. Tente novamente mais tarde.');
    } on TimeoutException {
      throw Exception('Tempo de conexão esgotado. Verifique sua internet.');
    } on ConnectionException {
      throw Exception(
          'Falha na conexão. Verifique sua internet e tente novamente.');
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
          await dio.post(
            '${ApiConfig.baseUrl}/api/auth/logout',
            options: Options(
              headers: {
                ...ApiConfig.headers,
                'Authorization': 'Bearer $token',
              },
            ),
          );
        } catch (_) {
          // Ignora erro da API - sempre limpa dados locais
        }
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
          } catch (_) {
            // Cache corrompido - buscar da API
          }
        }
      }

      final response = await httpClient.get(
        '/api/perfil/me',
        config: _defaultConfig,
      );

      if (response.statusCode == 200) {
        final data = response.body;

        // API pode retornar dentro de 'dados' ou diretamente
        final userData = data.containsKey('dados')
            ? data['dados'] as Map<String, dynamic>
            : data;

        final userModel = UserModel.fromJson(userData);

        await secureStorage.write(
          key: _userKey,
          value: jsonEncode(userModel.toJson()),
        );

        return userModel;
      } else {
        throw Exception('Falha ao obter dados do usuário');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Token inválido - força novo login
        await secureStorage.delete(key: _tokenKey);
        await secureStorage.delete(key: _userKey);
        throw Exception('Sessão expirada. Faça login novamente.');
      }
      throw Exception('Erro ao obter usuário: ${e.message}');
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
      final response = await dio.get(
        '${ApiConfig.baseUrl}/api/auth/validate',
        options: Options(
          headers: {
            ...ApiConfig.headers,
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data['valid'] == true || data['valido'] == true;
        }
        return true; // Se retornou 200, consideramos válido
      }

      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return false; // Token inválido
      }
      throw Exception('Erro ao validar token: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao validar token: $e');
    }
  }

  // ===== Métodos para Recuperação de Senha =====

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
      return data['valid'] == true ||
          data['valido'] == true ||
          response.statusCode == 200;
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
        final userData = data.containsKey('dados')
            ? data['dados'] as Map<String, dynamic>
            : data;

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
