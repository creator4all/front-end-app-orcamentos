import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multimidiaapp/app/shared/core/http/app_http_client.dart';
import 'package:multimidiaapp/app/shared/core/http/http_request_config.dart';

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
  final AppHttpClient _client;
  final FlutterSecureStorage _storage;

  PartnerService(this._client, this._storage);

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// Listar todos os parceiros (apenas para administradores)
  Future<List<PartnerProfile>> listarTodos() async {
    print('🏢 Buscando lista de todos os parceiros...');

    final token = await _getToken();
    final response = await _client.get(
      '/api/partners',
      config: HttpRequestConfig(token: token),
    );
    print('📡 Resposta da API: ${response.body}');

    // Extrair dados da estrutura aninhada
    dynamic data;

    if (response.body['data'] != null && response.body['data'] is Map) {
      final innerData = response.body['data'] as Map<String, dynamic>;
      data = innerData['dados'] ?? innerData;
    } else {
      data = response.body['dados'] ?? response.body;
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

    final token = await _getToken();
    final response = await _client.get(
      '/api/parceiro/me',
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

    return PartnerProfile.fromMap(data);
  }

  /// Atualizar informações da própria empresa
  Future<PartnerProfile> atualizarParceiro(Map<String, dynamic> dados) async {
    print('🌐 Atualizando empresa: $dados');

    final token = await _getToken();
    final response = await _client.put(
      '/api/parceiro/me',
      data: dados,
      config: HttpRequestConfig(token: token),
    );
    print('📡 Resposta da API: ${response.body}');

    // Extrair dados da estrutura aninhada
    Map<String, dynamic> data;

    if (response.body['data'] != null && response.body['data'] is Map) {
      final innerData = response.body['data'] as Map<String, dynamic>;
      data = innerData['dados'] ?? innerData;
    } else {
      data = response.body['dados'] ?? response.body;
    }

    print('🔍 Dados extraídos: $data');

    return PartnerProfile.fromMap(data);
  }

  /// Upload de logo da empresa
  Future<PartnerProfile> uploadLogo(File imageFile) async {
    final token = await _getToken();
    final response = await _client.uploadFile(
      '/api/parceiro/me/logo',
      filePath: imageFile.path,
      fileField: 'logo',
      config: HttpRequestConfig(token: token),
    );

    final body = response.body;

    // Extrair dados da estrutura aninhada
    Map<String, dynamic> data;

    if (body['data'] != null && body['data'] is Map) {
      final innerData = body['data'] as Map<String, dynamic>;
      data = innerData['dados'] ?? innerData;
    } else {
      data = body['dados'] ?? body;
    }

    return PartnerProfile.fromMap(data);
  }
}
