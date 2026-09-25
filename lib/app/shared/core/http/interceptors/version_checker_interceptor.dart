import 'package:dio/dio.dart';

import '../../constants/http_constants.dart';
import '../http_response.dart';
import 'http_interceptor.dart';

/// Interceptor para verificar versão do app e forçar atualização
///
/// Envia os headers de identificação do app e delega ao [onUpdateRequired]
/// quando o backend responde 426 (Upgrade Required).
///
/// Exemplo de uso:
/// ```dart
/// HttpClientConfig(
///   interceptors: [
///     VersionCheckerInterceptor(
///       currentVersion: '1.0.0',
///       currentBuild: '34',
///       currentPlatform: 'android',
///       appIdentifier: 'br.com.multimidiaeducacional.parceiro',
///       onUpdateRequired: () {},
///     ),
///   ],
/// )
/// ```
class VersionCheckerInterceptor extends HttpInterceptor {
  final String currentVersion;
  final String currentBuild;
  final String currentPlatform;
  final String appIdentifier;
  final void Function()? onUpdateRequired;

  bool _updateRequired = false;

  VersionCheckerInterceptor({
    required this.currentVersion,
    this.currentBuild = '',
    this.currentPlatform = '',
    this.appIdentifier = '',
    this.onUpdateRequired,
  });

  @override
  void onRequest(HttpRequestInfo request) {
    request.headers['App-Version'] = currentVersion;
    if (currentBuild.isNotEmpty) {
      request.headers['App-Build'] = currentBuild;
    }
    if (currentPlatform.isNotEmpty) {
      request.headers['App-Platform'] = currentPlatform;
    }
    if (appIdentifier.isNotEmpty) {
      request.headers['App-Identifier'] = appIdentifier;
    }
    request.headers['User-Agent'] = HttpHeaders.userAgentValue;
  }

  @override
  void onResponse(HttpResponseBase response) {
    if (response.statusCode == 426) {
      _requireUpdate();
    }
  }

  @override
  Future<bool> onError(
    Exception error,
    HttpRequestInfo request,
    String responseMessage,
    String responsePayload,
  ) async {
    if (error is DioException && error.response?.statusCode == 426) {
      _requireUpdate();
    }
    return false;
  }

  void _requireUpdate() {
    if (_updateRequired) return;
    _updateRequired = true;
    onUpdateRequired?.call();
  }
}
