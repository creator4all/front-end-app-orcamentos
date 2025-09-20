class ApiConfig {
  // Para emulador Android use: 'http://10.0.2.2:8080'
  // Para dispositivo físico use: 'http://192.168.3.2:8080'
  // Para iOS Simulator use: 'http://localhost:8080'
  static const String _localBaseUrl =
      'http://192.168.3.2:8080'; // IP para dispositivo físico
  static const String _testBaseUrl =
      'https://test-api.multimidiaeducacional.com.br';
  static const String _productionBaseUrl =
      'https://api.multimidiaeducacional.com.br';

  // Current environment
  static const String _environment =
      'local'; // Options: 'local', 'test', 'production'

  // Get base URL based on environment
  static String get baseUrl {
    switch (_environment) {
      case 'local':
        return _localBaseUrl;
      case 'test':
        return _testBaseUrl;
      case 'production':
        return _productionBaseUrl;
      default:
        return _localBaseUrl;
    }
  }

  // API endpoints
  static String get loginEndpoint => '$baseUrl/api/auth/login';
  static String get signInEndpoint => '$baseUrl/api/signin';
  static String get signUpEndpoint => '$baseUrl/api/signup';
  static String get resetPasswordEndpoint => '$baseUrl/api/reset-password';
  static String get userProfileEndpoint => '$baseUrl/api/user/profile';

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
