import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multimidiaapp/app/shared/core/http/app_http_client.dart';
import 'package:multimidiaapp/app/shared/core/http/http_request_config.dart';

import '../../domain/models/partner_profile.dart';

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

  Future<List<PartnerProfile>> listarTodos() async {
    final token = await _getToken();
    final response = await _client.get(
      '/api/partners',
      config: HttpRequestConfig(token: token),
    );

    final dados = response.body['dados'] as Map<String, dynamic>;
    final List data = dados['data'] as List;

    return data
        .map((item) => PartnerProfile.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<PartnerProfile> obterParceiro() async {
    final token = await _getToken();
    final response = await _client.get(
      '/api/parceiro/me',
      config: HttpRequestConfig(token: token),
    );

    final data = response.body['dados'] as Map<String, dynamic>;
    return PartnerProfile.fromMap(data);
  }

  Future<PartnerProfile> atualizarParceiro(Map<String, dynamic> dados) async {
    final token = await _getToken();
    final response = await _client.put(
      '/api/parceiro/me',
      data: dados,
      config: HttpRequestConfig(token: token),
    );

    final data = response.body['dados'] as Map<String, dynamic>;
    return PartnerProfile.fromMap(data);
  }

  Future<PartnerProfile> uploadLogo(File imageFile) async {
    final token = await _getToken();
    final response = await _client.uploadFile(
      '/api/parceiro/me/logo',
      filePath: imageFile.path,
      fileField: 'logo',
      config: HttpRequestConfig(token: token),
    );

    final data = response.body['dados'] as Map<String, dynamic>;
    return PartnerProfile.fromMap(data);
  }
}
