import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../widgets/custom_info_dialog.dart';
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

  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=br.com.multimidiaeducacional.parceiro';

  /// URL da App Store - aguardando finalização do review da Apple
  static const _appStoreUrl = '';

  VersionCheckerInterceptor({
    required this.currentVersion,
    this.onUpdateRequired,
    this.navigatorKey,
  });

  @override
  void onRequest(HttpRequestInfo request) {
    request.headers['App-Version'] = currentVersion;
    request.headers['User-Agent'] = 'App-Orcamentos-$currentVersion';
  }

  @override
  void onResponse(HttpResponseBase response) {
    if (response.statusCode == 426) {
      _showUpdateDialog();
    }

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
    if (error is DioException && error.response?.statusCode == 426) {
      _showUpdateDialog();
    }
    return false;
  }

  String? _getRequiredVersion(Map<String, List<String>> headers) {
    for (var entry in headers.entries) {
      if (entry.key.toLowerCase() == 'x-required-version' ||
          entry.key.toLowerCase() == 'x-min-version') {
        return entry.value.isNotEmpty ? entry.value.first : null;
      }
    }
    return null;
  }

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

      return false;
    } catch (e) {
      return false;
    }
  }

  void _showUpdateDialog() {
    if (_dialogIsVisible) return;

    final context = navigatorKey?.currentContext;
    if (context == null) {
      return;
    }

    _dialogIsVisible = true;

    if (onUpdateRequired != null) {
      onUpdateRequired!(context);
    } else {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.warning,
        title: 'Atualização Necessária',
        message:
            'Uma nova versão do app está disponível. Atualize para continuar usando.',
        buttonText: 'ATUALIZAR',
        barrierDismissible: false,
        onButtonPressed: _openStore,
      );
    }
  }

  Future<void> _openStore() async {
    final url = Platform.isIOS ? _appStoreUrl : _playStoreUrl;

    if (url.isEmpty) {
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}