enum Environment { local, localCasa, test, production }

class ApiConfig {
  static const String _localBaseUrl = 'http://192.168.68.54:8080';
  static const String _localBaseUrlCasa = 'http://192.168.1.13:8080';
  static const String _testBaseUrl =
      'https://test-api.multimidiaeducacional.com.br';
  static const String _productionBaseUrl =
      'https://parceiro.multimidiaeducacional.com.br';

  static Environment _currentEnvironment = Environment.production;

  static void init(Environment environment) {
    _currentEnvironment = environment;
  }

  static Environment get currentEnvironment => _currentEnvironment;

  static String get baseUrl {
    switch (_currentEnvironment) {
      case Environment.local:
        return _localBaseUrl;
      case Environment.localCasa:
        return _localBaseUrlCasa;
      case Environment.test:
        return _testBaseUrl;
      case Environment.production:
        return _productionBaseUrl;
    }
  }

  static String get loginEndpoint => '$baseUrl/api/auth/login';
  static String get signInEndpoint => '$baseUrl/api/signin';
  static String get signUpEndpoint => '$baseUrl/api/signup';
  static String get resetPasswordEndpoint => '$baseUrl/api/reset-password';
  static String get userProfileEndpoint => '$baseUrl/api/user/profile';
  static String get estadosEndpoint => '$baseUrl/api/estados';
  static String get cidadesEndpoint => '$baseUrl/api/cidades';
  static String get gruposCensoEndpoint => '$baseUrl/api/grupos-censo';
  static String censoPorCidadeEndpoint(int cidadeId) =>
      '$baseUrl/api/cidades/$cidadeId';

  static const Duration requestTimeout = Duration(seconds: 30);

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> headersWithToken(String token) => {
        ...headers,
        'Authorization': 'Bearer $token',
      };
}
