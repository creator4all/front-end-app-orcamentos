import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/token_cache.dart';

class SessionExpirationHandler {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data';

  static SessionExpirationHandler? current;

  final Future<void> Function() clearCredentials;
  final Future<void> Function() clearAuthenticatedState;
  final void Function() navigateToLogin;

  bool _isHandling = false;
  bool _sessionInvalidated = false;

  SessionExpirationHandler({
    required this.clearCredentials,
    required this.clearAuthenticatedState,
    required this.navigateToLogin,
  });

  static SessionExpirationHandler createDefault({
    required FlutterSecureStorage storage,
    required Future<void> Function() clearAuthenticatedState,
    required void Function() navigateToLogin,
  }) {
    return SessionExpirationHandler(
      clearCredentials: () async {
        await storage.delete(key: _tokenKey);
        await storage.delete(key: _userKey);
      },
      clearAuthenticatedState: clearAuthenticatedState,
      navigateToLogin: navigateToLogin,
    );
  }

  static void arm() {
    current?._sessionInvalidated = false;
  }

  static Future<void> handleUnauthorized() async {
    await current?._handleUnauthorized();
  }

  Future<void> _handleUnauthorized() async {
    if (_isHandling || _sessionInvalidated) return;

    _isHandling = true;
    _sessionInvalidated = true;
    try {
      await clearCredentials();
      TokenCache.instance.clearToken();
      await clearAuthenticatedState();
      navigateToLogin();
    } finally {
      _isHandling = false;
    }
  }
}
