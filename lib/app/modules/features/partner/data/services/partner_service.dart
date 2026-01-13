import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:multimidiaapp/config/api_config.dart';
import 'package:multimidiaapp/services/api_service.dart';

import '../../domain/models/partner_profile.dart';

/// Exceção customizada para erros de validação
class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic>? validationErrors;

  ValidationException(this.message, {this.validationErrors});

  @override
  String toString() => message;
}

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
      throw Exception(
          'Formato de resposta inválido - esperado lista de parceiros');
    }

    return (data)
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

    return PartnerProfile.fromMap(data);
  }

  /// Upload de logo da empresa
  Future<PartnerProfile> uploadLogo(File imageFile) async {
    print('📤 Fazendo upload do logo...');

    // Logs detalhados para debugging
    print('📁 Arquivo selecionado: ${imageFile.path}');
    final fileSize = await imageFile.length();
    print(
        '📏 Tamanho do arquivo: $fileSize bytes (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)');

    final extension = imageFile.path.split('.').last.toLowerCase();
    print('📝 Extensão do arquivo: $extension');

    final token = await _storage.read(key: 'auth_token');

    if (token == null) {
      throw Exception('Token não encontrado');
    }

    // Criar multipart request
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/parceiro/me/logo');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    // Adicionar arquivo com content-type explícito como image/jpeg
    // O ImageCropper sempre converte para JPG, mas o nome do arquivo temporário
    // pode confundir a detecção automática de MIME type
    final file = await http.MultipartFile.fromPath(
      'logo',
      imageFile.path,
      contentType: http.MediaType('image', 'jpeg'),
    );

    print('📦 Content-Type enviado: ${file.contentType}');
    request.files.add(file);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('📡 Status code: ${response.statusCode}');
    print('📡 Response body: ${response.body}');

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);

      // Extrair mensagem específica do erro de logo se existir
      String errorMessage = error['mensagem'] ?? 'Erro ao fazer upload do logo';
      Map<String, dynamic>? validationErrors;

      if (error['erros'] != null && error['erros'] is Map) {
        validationErrors = error['erros'] as Map<String, dynamic>;

        // Se há erro específico no campo 'logo', extrair a mensagem
        if (validationErrors['logo'] != null) {
          final logoErrors = validationErrors['logo'];
          if (logoErrors is Map) {
            // Pegar a primeira mensagem de erro
            errorMessage = logoErrors.values.first.toString();
          }
        }
      }

      print('❌ Erro de validação: $errorMessage');
      throw ValidationException(errorMessage,
          validationErrors: validationErrors);
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
