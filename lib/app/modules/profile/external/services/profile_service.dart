import 'package:multimidiaapp/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../../domain/models/user_profile.dart';
import '../../../../../config/api_config.dart';

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

    if (data is! Map<String, dynamic>) {
      throw Exception('Formato de resposta inválido');
    }

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

    if (data is! Map<String, dynamic>) {
      throw Exception('Formato de resposta inválido');
    }

    return UserProfile.fromMap(data);
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
    
    // Adicionar arquivo
    request.files.add(
      await http.MultipartFile.fromPath(
        'avatar',
        imageFile.path,
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
}
