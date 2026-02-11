import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multimidiaapp/app/shared/core/http/app_http_client.dart';
import 'package:multimidiaapp/app/shared/core/http/http_request_config.dart';

import '../models/user_profile_model.dart';
import 'profile_datasource.dart';

class ProfileApiDatasource implements ProfileDatasource {
  final AppHttpClient _client;
  final FlutterSecureStorage _storage;

  ProfileApiDatasource(this._client, {FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// A API retorna `{success, data: {sucesso, dados: {...}}}` ou variações.
  Map<String, dynamic> _extractProfileData(Map<String, dynamic> body) {
    if (body['data'] != null && body['data'] is Map) {
      final innerData = body['data'] as Map<String, dynamic>;
      return (innerData['dados'] ?? innerData) as Map<String, dynamic>;
    }
    return (body['dados'] ?? body) as Map<String, dynamic>;
  }

  @override
  Future<UserProfileModel> getProfile() async {
    final token = await _getToken();
    final response = await _client.get(
      '/api/perfil/me',
      config: HttpRequestConfig(token: token),
    );

    final data = _extractProfileData(response.body);
    return UserProfileModel.fromJson(data);
  }

  @override
  Future<UserProfileModel> updateProfile(Map<String, dynamic> data) async {
    final token = await _getToken();
    final response = await _client.put(
      '/api/perfil/me',
      data: data,
      config: HttpRequestConfig(token: token),
    );

    final responseData = _extractProfileData(response.body);
    return UserProfileModel.fromJson(responseData);
  }

  @override
  Future<String> deleteAccount() async {
    final token = await _getToken();
    final response = await _client.delete(
      '/api/perfil/me',
      config: HttpRequestConfig(token: token),
    );

    if (response.body['data'] != null && response.body['data'] is Map) {
      final innerData = response.body['data'] as Map<String, dynamic>;
      if (innerData['dados'] != null && innerData['dados'] is Map) {
        return (innerData['dados']['mensagem'] as String?) ??
            'Conta excluída com sucesso';
      }
    } else if (response.body['dados'] != null &&
        response.body['dados'] is Map) {
      return (response.body['dados']['mensagem'] as String?) ??
          'Conta excluída com sucesso';
    }

    return 'Conta excluída com sucesso';
  }

  @override
  Future<UserProfileModel> uploadAvatar(File imageFile) async {
    final token = await _getToken();
    final response = await _client.uploadFile(
      '/api/perfil/me/avatar',
      filePath: imageFile.path,
      fileField: 'avatar',
      config: HttpRequestConfig(token: token),
    );

    final data = _extractProfileData(response.body);
    return UserProfileModel.fromJson(data);
  }

  @override
  Future<UserProfileModel> removeAvatar() async {
    final token = await _getToken();
    final response = await _client.delete(
      '/api/perfil/me/avatar',
      config: HttpRequestConfig(token: token),
    );

    final data = _extractProfileData(response.body);
    return UserProfileModel.fromJson(data);
  }
}
