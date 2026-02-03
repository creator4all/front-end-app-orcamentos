/// Ambientes disponíveis para a aplicação
enum Environment { local, localCasa, test, production }

class ApiConfig {
  // Para emulador Android use: 'http://10.0.2.2:8080'
  // Para dispositivo físico use: 'http://192.168.3.2:8080'
  // Para iOS Simulator use: 'http://localhost:8080'
  static const String _localBaseUrl = 'http://192.168.68.54:8080';
  static const String _localBaseUrlCasa = 'http://192.168.1.13:8080';
  static const String _testBaseUrl =
      'https://test-api.multimidiaeducacional.com.br';
  static const String _productionBaseUrl =
      'https://parceiro.multimidiaeducacional.com.br';

  // Ambiente atual - altere aqui para trocar o apontamento
  static Environment _currentEnvironment = Environment.localCasa;

  /// Inicializa o ambiente em runtime (opcional)
  static void init(Environment environment) {
    _currentEnvironment = environment;
  }

  /// Retorna o ambiente atual
  static Environment get currentEnvironment => _currentEnvironment;

  /// Retorna a URL base de acordo com o ambiente
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

  // API endpoints
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

  // Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent':
            'App-Orcamentos-V1', // User-Agent específico para evitar OTP
      };

  // Headers with authentication token
  static Map<String, String> headersWithToken(String token) => {
        ...headers,
        'Authorization': 'Bearer $token',
      };
}
