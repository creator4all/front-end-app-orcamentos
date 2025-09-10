class ApiConstants {
  static const String baseUrl =
      'https://api.example.com'; // Substitua pela sua URL
  static const String apiVersion = 'v1';

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh';

  // Budget endpoints
  static const String budgetsEndpoint = '/budgets';

  // Partner endpoints
  static const String partnersEndpoint = '/partners';
  static const String cnpjSearchEndpoint = '/partners/cnpj';

  // Profile endpoints
  static const String profileEndpoint = '/profile';

  // Headers
  static const String authHeader = 'Authorization';
  static const String contentTypeHeader = 'Content-Type';
  static const String acceptHeader = 'Accept';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';
}
