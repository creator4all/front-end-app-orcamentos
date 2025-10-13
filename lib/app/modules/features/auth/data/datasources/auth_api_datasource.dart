import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../../../config/api_config.dart';
import '../models/user_model.dart';
import 'auth_datasource.dart';

/// Implementação do DataSource de autenticação usando Dio
/// Responsável por fazer chamadas HTTP e gerenciar armazenamento seguro
class AuthApiDatasource implements AuthDatasource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  // Keys para storage
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  AuthApiDatasource({
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

        // Validar estrutura da resposta
        if (data is! Map<String, dynamic>) {
          throw Exception(
              'Resposta da API inválida: esperado Map<String, dynamic>');
        }

        if (!data.containsKey('dados')) {
          throw Exception(
              'Resposta da API inválida: chave "dados" não encontrada');
        }

        final dadosResponse = data['dados'] as Map<String, dynamic>;

        // === PASSO 1: Salvar token ===
        if (dadosResponse.containsKey('token') &&
            dadosResponse['token'] != null) {
          final token = dadosResponse['token'].toString();
          await secureStorage.write(
            key: _tokenKey,
            value: token,
          );

          print('✅ Token salvo com sucesso');
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
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      // Tratar erros do Dio com mensagens amigáveis
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
        // Erro de rede
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          throw Exception('Tempo de conexão esgotado. Verifique sua internet.');
        } else if (e.type == DioExceptionType.connectionError) {
          throw Exception(
              'Falha na conexão. Verifique sua internet e tente novamente.');
        } else {
          throw Exception('Erro de rede: ${e.message}');
        }
      }
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
