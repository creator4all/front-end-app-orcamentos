import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../http_response.dart';
import 'http_interceptor.dart';

/// Interceptor para verificar versão do app e forçar atualização
///
/// Monitora o header 'App-Version' nas respostas e compara com a versão atual.
/// Quando o backend retorna status 426 (Upgrade Required), pode exibir
/// um diálogo forçando o usuário a atualizar o app.
///
/// Exemplo de uso:
/// ```dart
/// HttpClientConfig(
///   interceptors: [
///     VersionCheckerInterceptor(
///       currentVersion: '1.0.0',
///       onUpdateRequired: (context) {
///         showDialog(...); // Mostrar diálogo de atualização
///       },
///     ),
///   ],
/// )
/// ```
class VersionCheckerInterceptor extends HttpInterceptor {
  final String currentVersion;
  final Function(BuildContext?)? onUpdateRequired;
  final GlobalKey<NavigatorState>? navigatorKey;

  bool _dialogIsVisible = false;

  VersionCheckerInterceptor({
    required this.currentVersion,
    this.onUpdateRequired,
    this.navigatorKey,
  });

  @override
  void onRequest(HttpRequestInfo request) {
    // Adiciona versão do app nos headers de todas as requisições
    request.headers['App-Version'] = currentVersion;
    request.headers['User-Agent'] = 'OrcamentosApp/$currentVersion';
  }

  @override
  void onResponse(HttpResponseBase response) {
    // Status 426 = Upgrade Required (versão desatualizada)
    if (response.statusCode == 426) {
      _showUpdateDialog();
    }

    // Verifica header de versão mínima requerida
    final requiredVersion = _getRequiredVersion(response.headers);
    if (requiredVersion != null && _isVersionOutdated(requiredVersion)) {
      _showUpdateDialog();
    }
  }

  @override
  Future<bool> onError(
    Exception error,
    HttpRequestInfo request,
    String responseMessage,
    String responsePayload,
  ) async {
    // Verifica se o erro é por versão desatualizada
    if (error is DioException && error.response?.statusCode == 426) {
      _showUpdateDialog();
    }
    return false;
  }

  /// Extrai versão mínima requerida dos headers
  String? _getRequiredVersion(Map<String, List<String>> headers) {
    for (var entry in headers.entries) {
      if (entry.key.toLowerCase() == 'x-required-version' ||
          entry.key.toLowerCase() == 'x-min-version') {
        return entry.value.isNotEmpty ? entry.value.first : null;
      }
    }
    return null;
  }

  /// Compara versões (formato: 1.2.3)
  bool _isVersionOutdated(String requiredVersion) {
    try {
      final current = currentVersion.split('.').map(int.parse).toList();
      final required = requiredVersion.split('.').map(int.parse).toList();

      for (var i = 0; i < 3; i++) {
        final currentPart = i < current.length ? current[i] : 0;
        final requiredPart = i < required.length ? required[i] : 0;

        if (currentPart < requiredPart) return true;
        if (currentPart > requiredPart) return false;
      }

      return false; // Versões iguais
    } catch (e) {
      return false;
    }
  }

  /// Mostra diálogo de atualização obrigatória
  void _showUpdateDialog() {
    if (_dialogIsVisible) return;

    final context = navigatorKey?.currentContext;
    if (context == null) {
      debugPrint(
          '⚠️ VersionCheckerInterceptor: Context não disponível para mostrar diálogo');
      return;
    }

    _dialogIsVisible = true;

    if (onUpdateRequired != null) {
      onUpdateRequired!(context);
    } else {
      // Diálogo padrão
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Atualização Necessária'),
          content: const Text(
            'Uma nova versão do aplicativo está disponível. '
            'Por favor, atualize para continuar usando.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Implementar lógica de redirecionamento para loja
                // Exemplo: launch('https://play.google.com/store/apps/details?id=...');
              },
              child: const Text('ATUALIZAR'),
            ),
          ],
        ),
      );
    }
  }
}
