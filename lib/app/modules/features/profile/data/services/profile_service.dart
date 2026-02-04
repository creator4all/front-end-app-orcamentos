import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:multimidiaapp/app/shared/core/http/app_http_client.dart';
import 'package:multimidiaapp/app/shared/core/http/http_request_config.dart';
import 'package:multimidiaapp/config/api_config.dart';

import '../../domain/models/user_profile.dart';

class ProfileService {
  final AppHttpClient _client;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ProfileService(this._client);

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// Obtém perfil do usuário logado
  Future<UserProfile> obterPerfil() async {
    print('🌐 Buscando perfil do usuário...');

    final token = await _getToken();
    final response = await _client.get(
      '/api/perfil/me',
      config: HttpRequestConfig(token: token),
    );
    print('📡 Resposta da API: ${response.body}');

    // Extrair dados da estrutura aninhada: {success, data: {sucesso, dados}}
    Map<String, dynamic> data;

    if (response.body['data'] != null && response.body['data'] is Map) {
      // Se tem 'data', pegar de dentro dele
      final innerData = response.body['data'] as Map<String, dynamic>;
      data = innerData['dados'] ?? innerData;
    } else {
      // Caso contrário, tentar pegar 'dados' direto
      data = response.body['dados'] ?? response.body;
    }

    print('🔍 Dados extraídos: $data');

    return UserProfile.fromMap(data);
  }

  /// Atualiza perfil do usuário logado
  Future<UserProfile> atualizarPerfil(Map<String, dynamic> dados) async {
    print('🌐 Atualizando perfil: $dados');

    final token = await _getToken();
    final response = await _client.put(
      '/api/perfil/me',
      data: dados,
      config: HttpRequestConfig(token: token),
    );
    print('📡 Resposta da API: ${response.body}');

    // Extrair dados da estrutura aninhada: {success, data: {sucesso, dados}}
    Map<String, dynamic> data;

    if (response.body['data'] != null && response.body['data'] is Map) {
      final innerData = response.body['data'] as Map<String, dynamic>;
      data = innerData['dados'] ?? innerData;
    } else {
      data = response.body['dados'] ?? response.body;
    }

    print('🔍 Dados extraídos: $data');

    return UserProfile.fromMap(data);
  }

  /// Deleta conta do usuário logado
  /// Retorna a mensagem de sucesso da API
  Future<String> deletarConta() async {
    print('🌐 Deletando conta do usuário...');

    final token = await _getToken();
    final response = await _client.delete(
      '/api/perfil/me',
      config: HttpRequestConfig(token: token),
    );
    print('📡 Resposta da API: ${response.body}');

    // Extrair mensagem da estrutura: {success, data: {dados: {mensagem}}}
    String mensagem = 'Conta excluída com sucesso';

    if (response.body['data'] != null && response.body['data'] is Map) {
      final innerData = response.body['data'] as Map<String, dynamic>;
      if (innerData['dados'] != null && innerData['dados'] is Map) {
        mensagem = innerData['dados']['mensagem'] ?? mensagem;
      }
    } else if (response.body['dados'] != null &&
        response.body['dados'] is Map) {
      mensagem = response.body['dados']['mensagem'] ?? mensagem;
    }

    print('✅ Conta deletada: $mensagem');
    return mensagem;
  }

  /// Upload de avatar
  /// Usa http package multipart porque AppHttpClient não suporta multipart forms
  Future<UserProfile> uploadAvatar(File imageFile) async {
    print('🌐 Fazendo upload do avatar...');

    final token = await _getToken();
    final baseUrl = ApiConfig.baseUrl;

    final uri = Uri.parse('$baseUrl/api/perfil/me/avatar');
    final request = http.MultipartRequest('POST', uri);

    // Adicionar token de autenticação
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Adicionar arquivo com contentType explícito para garantir MIME type correto
    request.files.add(
      await http.MultipartFile.fromPath(
        'avatar',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('📡 Status do upload: ${response.statusCode}');
    print('📡 Resposta: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Erro ao fazer upload do avatar: ${response.body}');
    }

    // Parse da resposta
    final jsonResponse = json.decode(response.body);
    final data = jsonResponse['dados'] ?? jsonResponse['data'] ?? jsonResponse;

    if (data is! Map<String, dynamic>) {
      throw Exception('Formato de resposta inválido');
    }

    return UserProfile.fromMap(data);
  }

  /// Remove o avatar do usuário logado
  Future<UserProfile> removerAvatar() async {
    print('🌐 Removendo avatar...');

    final token = await _getToken();
    final response = await _client.delete(
      '/api/perfil/me/avatar',
      config: HttpRequestConfig(token: token),
    );
    print('📡 Resposta da API: ${response.body}');

    Map<String, dynamic> data;
    if (response.body['data'] != null && response.body['data'] is Map) {
      final innerData = response.body['data'] as Map<String, dynamic>;
      data = innerData['dados'] ?? innerData;
    } else {
      data = response.body['dados'] ?? response.body;
    }

    print('🔍 Dados extraídos: $data');

    return UserProfile.fromMap(data);
  }
}
