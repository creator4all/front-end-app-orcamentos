import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/token_cache.dart';

class SessionExpirationHandler {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data';
  static bool _isHandling = false;

  static Future<void> handleUnauthorized() async {
    if (_isHandling) return;

    _isHandling = true;
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
      TokenCache.instance.clearToken();

      Modular.to.pushReplacementNamed('/auth/login');
    } finally {
      _isHandling = false;
    }
  }
}
