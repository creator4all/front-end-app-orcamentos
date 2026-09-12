import 'package:patrol/patrol.dart';

/// Configuração padrão usada por todos os testes Patrol da suíte mobile do
/// app Multimídia: Parceiro.
///
/// Os testes rodam contra um emulador Android com o backend acessível em
/// `http://10.0.2.2:8088` (proxy `socat` para o host do webservice).
///
const PatrolTesterConfig patrolConfig = PatrolTesterConfig(
  settlePolicy: SettlePolicy.trySettle,
  existsTimeout: Duration(seconds: 30),
  visibleTimeout: Duration(seconds: 30),
  settleTimeout: Duration(seconds: 30),
  printLogs: true,
);

/// Credenciais fornecidas em tempo de execução via `--dart-define`.
const String sellerEmail = String.fromEnvironment('PATROL_SELLER_EMAIL');
const String sellerPassword = String.fromEnvironment('PATROL_SELLER_PASSWORD');
const String adminEmail = String.fromEnvironment('PATROL_ADMIN_EMAIL');
const String adminPassword = String.fromEnvironment('PATROL_ADMIN_PASSWORD');
const String mobileFixtureApiUrl = String.fromEnvironment(
  'PATROL_MOBILE_FIXTURE_API_URL',
  defaultValue: 'http://10.0.2.2:8088/api/test/mobile-fixtures',
);
const String mobileFixtureApiKey =
    String.fromEnvironment('PATROL_MOBILE_FIXTURE_API_KEY');
const String mobileFixturePassword =
    String.fromEnvironment('PATROL_MOBILE_FIXTURE_PASSWORD');
