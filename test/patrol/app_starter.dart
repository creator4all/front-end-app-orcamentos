import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multimidiaapp/app/shared/core/utils/token_cache.dart';
import 'package:multimidiaapp/main.dart' as app;
import 'package:patrol/patrol.dart';

/// Pacote do app Android.
const String appPackageName = 'br.com.multimidiaeducacional.parceiro';

/// Inicia o app a partir de `main.dart` e aguarda a primeira tela estável.
///
/// Cada `patrolTest` chama `app.main()` para reiniciar o app do zero,
/// garantindo que a tela inicial (login) seja exibida.
Future<void> startApp(PatrolIntegrationTester $) async {
  await app.main();
  await $.pumpAndSettle();
}

/// Inicia o app sem a sessão persistida do teste anterior.
Future<void> startAppClean(PatrolIntegrationTester $) async {
  const storage = FlutterSecureStorage();
  await storage.delete(key: 'auth_token');
  await storage.delete(key: 'user_data');
  TokenCache.instance.clearToken();
  await app.main();
  await $.pumpAndSettle();
}
