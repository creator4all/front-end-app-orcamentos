import 'dart:io';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:multimidiaapp/services/api_service.dart';
import 'package:multimidiaapp/config/api_config.dart';
import '../../domain/models/partner_profile.dart';

class PartnerService {
  final ApiService _api;
  final FlutterSecureStorage _storage;

  PartnerService(this._api, this._storage);

  /// Listar todos os parceiros (apenas para administradores)
  Future<List<PartnerProfile>> listarTodos() async {
    print('🏢 Buscando lista de todos os parceiros...');
    
    final token = await _storage.read(key: 'auth_token');
    final res = await _api.get('/api/partners', token: token);
    print('📡 Resposta da API: $res');

    // Extrair dados da estrutura aninhada
    dynamic data;
    
    if (res['data'] != null && res['data'] is Map) {
      final innerData = res['data'] as Map<String, dynamic>;
      data = innerData['dados'] ?? innerData;
    } else {
      data = res['dados'] ?? res;
    }

    print('🔍 Dados extraídos: $data');

    // Se for paginado, extrair o array 'data'
    if (data is Map && data['data'] != null) {
      data = data['data'];
    }

    if (data is! List) {
      throw Exception('Formato de resposta inválido - esperado lista de parceiros');
    }

    return (data as List)
        .map((item) => PartnerProfile.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  /// Buscar informações da própria empresa
  Future<PartnerProfile> obterParceiro() async {
    print('🏢 Buscando informações da empresa...');
    
    final token = await _storage.read(key: 'auth_token');
    final res = await _api.get('/api/parceiro/me', token: token);
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

    return PartnerProfile.fromMap(data);
  }

  /// Atualizar informações da própria empresa
  Future<PartnerProfile> atualizarParceiro(Map<String, dynamic> dados) async {
    print('🌐 Atualizando empresa: $dados');
    
    final token = await _storage.read(key: 'auth_token');
    final res = await _api.put('/api/parceiro/me', dados, token: token);
    print('📡 Resposta da API: $res');

    // Extrair dados da estrutura aninhada
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

    return PartnerProfile.fromMap(data);
  }

  /// Upload de logo da empresa
  Future<PartnerProfile> uploadLogo(File imageFile) async {
    print('📤 Fazendo upload do logo...');
    
    final token = await _storage.read(key: 'auth_token');
    
    if (token == null) {
      throw Exception('Token não encontrado');
    }

    // Criar multipart request
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/parceiro/me/logo');
    final request = http.MultipartRequest('POST', uri);
    
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('logo', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('📡 Status code: ${response.statusCode}');
    print('📡 Response body: ${response.body}');

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['mensagem'] ?? 'Erro ao fazer upload do logo');
    }

    final res = jsonDecode(response.body);

    // Extrair dados da estrutura aninhada
    Map<String, dynamic> data;
    
    if (res['data'] != null && res['data'] is Map) {
      final innerData = res['data'] as Map<String, dynamic>;
      data = innerData['dados'] ?? innerData;
    } else {
      data = res['dados'] ?? res;
    }

    return PartnerProfile.fromMap(data);
  }
}
