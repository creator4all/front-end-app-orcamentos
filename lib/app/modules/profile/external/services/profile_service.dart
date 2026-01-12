import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:multimidiaapp/services/api_service.dart';

import '../../../../../config/api_config.dart';
import '../../domain/models/user_profile.dart';

class ProfileService {
  final ApiService _api;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ProfileService(this._api);

  /// Obtém perfil do usuário logado
  Future<UserProfile> obterPerfil() async {
    print('🌐 Buscando perfil do usuário...');

    final token = await _storage.read(key: 'auth_token');
    final res = await _api.get('/api/perfil/me', token: token);
    print('📡 Resposta da API: $res');

    // Extrair dados da estrutura aninhada: {success, data: {sucesso, dados}}
    Map<String, dynamic> data;

    if (res['data'] != null && res['data'] is Map) {
      // Se tem 'data', pegar de dentro dele
      final innerData = res['data'] as Map<String, dynamic>;
      data = innerData['dados'] ?? innerData;
    } else {
      // Caso contrário, tentar pegar 'dados' direto
      data = res['dados'] ?? res;
    }

    print('🔍 Dados extraídos: $data');

    return UserProfile.fromMap(data);
  }

  /// Atualiza perfil do usuário logado
  Future<UserProfile> atualizarPerfil(Map<String, dynamic> dados) async {
    print('🌐 Atualizando perfil: $dados');

    final token = await _storage.read(key: 'auth_token');
    final res = await _api.put('/api/perfil/me', dados, token: token);
    print('📡 Resposta da API: $res');

    // Extrair dados da estrutura aninhada: {success, data: {sucesso, dados}}
    Map<String, dynamic> data;

    if (res['data'] != null && res['data'] is Map) {
      final innerData = res['data'] as Map<String, dynamic>;
      data = innerData['dados'] ?? innerData;
    } else {
      data = res['dados'] ?? res;
    }

    print('🔍 Dados extraídos: $data');

    return UserProfile.fromMap(data);
  }

  /// Deleta conta do usuário logado
  /// Retorna a mensagem de sucesso da API
  Future<String> deletarConta() async {
    print('🌐 Deletando conta do usuário...');

    final token = await _storage.read(key: 'auth_token');
    final res = await _api.delete('/api/perfil/me', token: token);
    print('📡 Resposta da API: $res');

    // Extrair mensagem da estrutura: {success, data: {dados: {mensagem}}}
    String mensagem = 'Conta excluída com sucesso';

    if (res['data'] != null && res['data'] is Map) {
      final innerData = res['data'] as Map<String, dynamic>;
      if (innerData['dados'] != null && innerData['dados'] is Map) {
        mensagem = innerData['dados']['mensagem'] ?? mensagem;
      }
    } else if (res['dados'] != null && res['dados'] is Map) {
      mensagem = res['dados']['mensagem'] ?? mensagem;
    }

    print('✅ Conta deletada: $mensagem');
    return mensagem;
  }

  /// Upload de avatar
  Future<UserProfile> uploadAvatar(File imageFile) async {
    print('🌐 Fazendo upload do avatar...');

    final token = await _storage.read(key: 'auth_token');
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

    final token = await _storage.read(key: 'auth_token');
    final res = await _api.delete('/api/perfil/me/avatar', token: token);
    print('📡 Resposta da API: $res');

    Map<String, dynamic> data;
    if (res['data'] != null && res['data'] is Map) {
      final innerData = res['data'] as Map<String, dynamic>;
      data = innerData['dados'] ?? innerData;
    } else {
      data = res['dados'] ?? res;
    }

    print('🔍 Dados extraídos: $data');

    return UserProfile.fromMap(data);
  }
}
