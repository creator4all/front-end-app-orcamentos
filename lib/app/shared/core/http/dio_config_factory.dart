import '../constants/http_constants.dart';
import 'http_client_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/http_interceptor.dart';
import 'interceptors/version_checker_interceptor.dart';

/// Factory para criar configurações do HttpClient
///
/// Facilita a criação de configurações para diferentes ambientes
/// e cenários de uso.
class DioConfigFactory {
  /// Cria configuração padrão
  ///
  /// Exemplo:
  /// ```dart
  /// final config = DioConfigFactory.createDefault(
  ///   baseUrl: 'https://api.exemplo.com',
  ///   getToken: () => authService.token,
  ///   enableLogger: true,
  /// );
  /// ```
  static HttpClientConfig createDefault({
    required String baseUrl,
    String Function()? getToken,
    bool enableLogger = false,
    Duration? timeout,
    List<HttpInterceptor>? additionalInterceptors,
    Map<String, String>? defaultHeaders,
  }) {
    final interceptors = <HttpInterceptor>[
      // Auth interceptor sempre primeiro
      if (getToken != null)
        AuthInterceptor(
          getToken: getToken,
          excludedPaths: ['/login', '/register', '/refresh-token'],
        ),

      // Adiciona interceptors customizados
      ...?additionalInterceptors,
    ];

    return HttpClientConfig(
      baseUrl: baseUrl,
      timeout: timeout ?? HttpTimeouts.defaultTimeout,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: timeout ?? HttpTimeouts.defaultTimeout,
      enableLogger: enableLogger,
      getToken: getToken,
      interceptors: interceptors,
      defaultHeaders: defaultHeaders,
      validateSsl: true,
      followRedirects: true,
      maxRedirects: 5,
    );
  }

  /// Cria configuração para desenvolvimento
  ///
  /// - Logger habilitado
  /// - Timeouts maiores
  /// - SSL validation desabilitada (opcional)
  static HttpClientConfig createForDevelopment({
    required String baseUrl,
    String Function()? getToken,
    bool validateSsl = false,
    List<HttpInterceptor>? additionalInterceptors,
  }) {
    return createDefault(
      baseUrl: baseUrl,
      getToken: getToken,
      enableLogger: true,
      timeout: HttpTimeouts.longTimeout,
      additionalInterceptors: additionalInterceptors,
      defaultHeaders: {
        'X-Environment': 'development',
      },
    ).copyWith(validateSsl: validateSsl);
  }

  /// Cria configuração para produção
  ///
  /// - Logger desabilitado
  /// - Timeouts padrão
  /// - SSL validation obrigatória
  /// - Inclui version checker
  static HttpClientConfig createForProduction({
    required String baseUrl,
    required String appVersion,
    String Function()? getToken,
    Function(dynamic)? onUpdateRequired,
    List<HttpInterceptor>? additionalInterceptors,
  }) {
    final interceptors = <HttpInterceptor>[
      // Version checker para forçar atualizações
      VersionCheckerInterceptor(
        currentVersion: appVersion,
        onUpdateRequired: onUpdateRequired,
      ),
      ...?additionalInterceptors,
    ];

    return createDefault(
      baseUrl: baseUrl,
      getToken: getToken,
      enableLogger: false,
      timeout: HttpTimeouts.defaultTimeout,
      additionalInterceptors: interceptors,
      defaultHeaders: {
        'X-Environment': 'production',
        'X-App-Version': appVersion,
      },
    );
  }

  /// Cria configuração para testes
  ///
  /// - Logger desabilitado
  /// - Timeouts curtos
  /// - Sem interceptors de retry
  static HttpClientConfig createForTesting({
    required String baseUrl,
    String Function()? getToken,
    List<HttpInterceptor>? interceptors,
  }) {
    return HttpClientConfig(
      baseUrl: baseUrl,
      timeout: HttpTimeouts.shortTimeout,
      connectTimeout: HttpTimeouts.shortTimeout,
      receiveTimeout: HttpTimeouts.shortTimeout,
      enableLogger: false,
      getToken: getToken,
      interceptors: interceptors,
      validateSsl: false,
    );
  }

  /// Cria configuração customizada completa
  static HttpClientConfig createCustom({
    required String baseUrl,
    Duration? timeout,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    bool enableLogger = false,
    String Function()? getToken,
    List<HttpInterceptor>? interceptors,
    Map<String, String>? defaultHeaders,
    bool validateSsl = true,
    bool followRedirects = true,
    int maxRedirects = 5,
  }) {
    return HttpClientConfig(
      baseUrl: baseUrl,
      timeout: timeout ?? HttpTimeouts.defaultTimeout,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      enableLogger: enableLogger,
      getToken: getToken,
      interceptors: interceptors,
      defaultHeaders: defaultHeaders,
      validateSsl: validateSsl,
      followRedirects: followRedirects,
      maxRedirects: maxRedirects,
    );
  }
}
