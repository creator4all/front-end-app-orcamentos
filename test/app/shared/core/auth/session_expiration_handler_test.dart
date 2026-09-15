import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/shared/core/auth/session_expiration_handler.dart';
import 'package:multimidiaapp/app/shared/core/utils/token_cache.dart';

void main() {
  late SessionExpirationHandler handler;
  var credentialClears = 0;
  var stateClears = 0;
  var navigations = 0;

  setUp(() {
    credentialClears = 0;
    stateClears = 0;
    navigations = 0;
    TokenCache.instance.clearToken();
    handler = SessionExpirationHandler(
      clearCredentials: () async {
        credentialClears++;
      },
      clearAuthenticatedState: () async {
        stateClears++;
      },
      navigateToLogin: () {
        navigations++;
      },
    );
    SessionExpirationHandler.current = handler;
  });

  tearDown(() {
    SessionExpirationHandler.current = null;
    TokenCache.instance.clearToken();
  });

  test('clears credentials, token cache and authenticated state once', () async {
    TokenCache.instance.setToken('stale-token');

    await SessionExpirationHandler.handleUnauthorized();
    await SessionExpirationHandler.handleUnauthorized();

    expect(credentialClears, 1);
    expect(stateClears, 1);
    expect(navigations, 1);
    expect(TokenCache.instance.hasToken(), isFalse);
  });

  test('concurrent 401s share a single coordinated cleanup', () async {
    handler = SessionExpirationHandler(
      clearCredentials: () async {
        credentialClears++;
        await Future<void>.delayed(const Duration(milliseconds: 20));
      },
      clearAuthenticatedState: () async {},
      navigateToLogin: () {},
    );
    SessionExpirationHandler.current = handler;

    await Future.wait([
      SessionExpirationHandler.handleUnauthorized(),
      SessionExpirationHandler.handleUnauthorized(),
      SessionExpirationHandler.handleUnauthorized(),
    ]);

    expect(credentialClears, 1);
  });
}
