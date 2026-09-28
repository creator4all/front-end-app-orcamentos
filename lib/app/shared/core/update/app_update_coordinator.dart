import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/custom_info_dialog.dart';

final appUpdateCoordinator = AppUpdateCoordinator();

class AppUpdateCoordinator {
  static const _packageIdentifier = 'br.com.multimidiaeducacional.parceiro';
  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=$_packageIdentifier';
  static const _appStoreUrl = 'https://apps.apple.com/br/app/id6756675057';
  static const _forceOptionalUpdate =
      bool.fromEnvironment('FORCE_OPTIONAL_UPDATE');

  final NewVersionPlus _storeVersion = NewVersionPlus(
    androidId: _packageIdentifier,
    iOSId: _packageIdentifier,
    iOSAppStoreCountry: 'BR',
    androidPlayStoreCountry: 'pt_BR',
  );

  GlobalKey<NavigatorState>? _navigatorKey;
  bool _checkedInCurrentProcess = false;
  bool _required = false;
  bool _requiredDialogVisible = false;
  bool _optionalDialogVisible = false;

  bool get isUpdateRequired => _required;

  void attachNavigator(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_required) {
        _showRequiredUpdate();
      }
    });
  }

  void requireUpdate() {
    _required = true;
    _dismissOptionalUpdate();
    _showRequiredUpdate();
  }

  Future<void> checkOptionalUpdateOnce() async {
    if (_checkedInCurrentProcess || _required) return;
    _checkedInCurrentProcess = true;

    if (kDebugMode && _forceOptionalUpdate) {
      _showOptionalUpdate(_fallbackStoreUrl());
      return;
    }

    try {
      final status = await _storeVersion.getVersionStatus();
      if (_required) return;
      if (status != null && status.canUpdate) {
        _showOptionalUpdate(status.appStoreLink);
      }
    } on Exception catch (error, stackTrace) {
      _reportError(error, stackTrace);
    }
  }

  void _showRequiredUpdate() {
    if (_requiredDialogVisible) return;
    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    _requiredDialogVisible = true;
    unawaited(
      CustomInfoDialog.show(
        context: context,
        type: DialogType.warning,
        title: 'Atualização necessária',
        message:
            'Para continuar usando o aplicativo, instale a versão mais recente.',
        buttonText: 'Atualizar aplicativo',
        barrierDismissible: false,
        canPop: false,
        closeOnButtonPressed: false,
        onButtonPressed: () => unawaited(_openStore(_fallbackStoreUrl())),
      ).whenComplete(() {
        _requiredDialogVisible = false;
        if (_required) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showRequiredUpdate();
          });
        }
      }),
    );
  }

  void _showOptionalUpdate(String storeUrl) {
    if (_optionalDialogVisible || _required) return;
    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    _optionalDialogVisible = true;
    unawaited(
      CustomInfoDialog.show(
        context: context,
        type: DialogType.info,
        title: 'Nova atualização disponível',
        message: 'Uma nova versão do aplicativo está disponível.',
        buttonText: 'Atualizar agora',
        secondaryButtonText: 'Mais tarde',
        onButtonPressed: () => unawaited(_openStore(storeUrl)),
      ).whenComplete(() => _optionalDialogVisible = false),
    );
  }

  void _dismissOptionalUpdate() {
    if (!_optionalDialogVisible) return;
    _navigatorKey?.currentState?.pop();
  }

  Future<void> _openStore(String url) async {
    try {
      final launched = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        _reportError(
          Exception('Não foi possível abrir a loja de aplicativos.'),
          StackTrace.current,
        );
      }
    } on Exception catch (error, stackTrace) {
      _reportError(error, stackTrace);
    }
  }

  String _fallbackStoreUrl() => Platform.isIOS ? _appStoreUrl : _playStoreUrl;

  void _reportError(Exception error, StackTrace stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'app update checker',
      ),
    );
  }
}
