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

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    print('🌐 AuthApiDatasource.login() iniciado');
    print('   URL: ${ApiConfig.loginEndpoint}');
    print('   Email: $email');

    try {
      print('📡 Fazendo POST para ${ApiConfig.loginEndpoint}...');

      // ✅ USANDO NOVO AppHttpClient com User-Agent customizado
      final response = await httpClient.post(
        ApiConfig.loginEndpoint,
        data: {
          'usr_email': email,
          'usr_password': password,
        },
        config: HttpRequestConfig(
          headers: {
            'User-Agent':
                'App-Orcamentos-V1', // ⚠️ OBRIGATÓRIO para evitar OTP em mobile
          },
        ),
      );

      // Processar resposta de sucesso
      final data = response.body;

      // Validar estrutura da resposta
      if (!data.containsKey('dados')) {
        throw Exception(
            'Resposta da API inválida: chave "dados" não encontrada');
      }

      final dadosResponse = data['dados'] as Map<String, dynamic>;

      // === PASSO 1: Salvar token ===
      if (dadosResponse.containsKey('token') &&
          dadosResponse['token'] != null) {
        final token = dadosResponse['token'].toString();

        // Salvar no SecureStorage
        await secureStorage.write(
          key: _tokenKey,
          value: token,
        );

        // Cachear no TokenCache para uso síncrono nos interceptors
        TokenCache.instance.setToken(token);

        print('✅ Token salvo com sucesso (SecureStorage + TokenCache)');
        print('📝 Token: ${token.substring(0, 20)}...');
      } else {
        throw Exception('Token não retornado pela API de login');
      }

      // === PASSO 2: SEMPRE buscar dados completos do usuário via /api/perfil/me ===
      print('🔍 Buscando dados completos do usuário via /api/perfil/me...');
      final userModel =
          await getCurrentUser(forceRefresh: true); // ⭐ FORÇA BUSCAR DA API

      // === PASSO 3: Salvar dados completos do usuário no cache ===
      await secureStorage.write(
        key: _userKey,
        value: jsonEncode(userModel.toJson()),
      );

      print('✅ Dados completos do usuário salvos no cache');

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
      print('❌ Erro inesperado: $e');
      throw Exception('Erro inesperado ao fazer login: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final token = await getStoredToken();

      if (token != null) {
        try {
          // Chamar endpoint de logout
          await dio.post(
            '${ApiConfig.baseUrl}/api/auth/logout',
            options: Options(
              headers: {
                ...ApiConfig.headers,
                'Authorization': 'Bearer $token',
              },
            ),
          );
        } catch (e) {
          // Mesmo se falhar na API, limpar dados locais
          print('Erro ao chamar logout na API: $e');
        }
      }

      // Limpar dados armazenados
      await secureStorage.delete(key: _tokenKey);
      await secureStorage.delete(key: _userKey);

      // Limpar token do cache em memória
      TokenCache.instance.clearToken();

      print('✅ Logout realizado: SecureStorage e TokenCache limpos');
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

      // Se forceRefresh = false, tentar buscar do cache primeiro
      if (!forceRefresh) {
        final cachedUser = await secureStorage.read(key: _userKey);
        if (cachedUser != null) {
          try {
            print(
                '📦 [getCurrentUser] Retornando do cache (forceRefresh=false)');
            final userJson = jsonDecode(cachedUser) as Map<String, dynamic>;
            return UserModel.fromJson(userJson);
          } catch (e) {
            print('⚠️ Erro ao decodificar usuário do cache: $e');
          }
        }
      } else {
        print('🔄 [getCurrentUser] forceRefresh=true - Ignorando cache');
      }

      // Se forceRefresh = true OU não houver cache, buscar da API
      print('🌐 Chamando GET /api/perfil/me...');
      final response = await dio.get(
        '${ApiConfig.baseUrl}/api/perfil/me',
        options: Options(
          headers: {
            ...ApiConfig.headers,
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        print('📦 Resposta completa da API:');
        print(data);

        if (data is! Map<String, dynamic>) {
          throw Exception('Resposta da API inválida');
        }

        // A API pode retornar dentro de 'dados' ou diretamente
        final userData = data.containsKey('dados')
            ? data['dados'] as Map<String, dynamic>
            : data;

        print('👤 Dados do usuário extraídos:');
        print(userData);

        final userModel = UserModel.fromJson(userData);

        print('✅ UserModel criado com sucesso:');
        print('   - ID: ${userModel.id}');
        print('   - Nome: ${userModel.name}');
        print('   - Email: ${userModel.email}');
        print('   - Role: ${userModel.role?.name ?? "N/A"}');
        print('   - Partner: ${userModel.partner?.tradeName ?? "N/A"}');
        print('   - Status: ${userModel.status}');

        // Atualizar cache
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
        // Token inválido - limpar e forçar novo login
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
}
