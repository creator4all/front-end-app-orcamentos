/// Configuração global do cliente HTTP
///
/// Define configurações padrão que serão aplicadas a todas as requisições,
/// a menos que sejam sobrescritas por [HttpRequestConfig]
class HttpClientConfig {
  /// URL base da API (ex: https://api.exemplo.com)
  final String baseUrl;

  /// Timeout padrão para todas as requisições
  final Duration timeout;

  /// Timeout de conexão (tempo para estabelecer conexão)
  final Duration? connectTimeout;

  /// Timeout de recebimento (tempo para receber resposta)
  final Duration? receiveTimeout;

  /// Habilita logs de requisições/respostas (útil para debug)
  final bool enableLogger;

  /// Função que retorna o token de autenticação dinamicamente
  ///
  /// Exemplo:
  /// ```dart
  /// getToken: () => authService.currentToken
  /// ```
  final String Function()? getToken;

  /// Callback chamado quando a API retorna 401.
  final Future<void> Function()? onUnauthorized;

  /// Lista de interceptadores customizados
  ///
  /// Interceptadores são executados em ordem antes/depois das requisições
  final List<dynamic>? interceptors;

  /// Headers padrão para todas as requisições
  final Map<String, String>? defaultHeaders;

  /// Validar certificados SSL (padrão: true)
  final bool validateSsl;

  /// Seguir redirects automaticamente (padrão: true)
  final bool followRedirects;

  /// Número máximo de redirects a seguir (padrão: 5)
  final int maxRedirects;

  HttpClientConfig({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    this.connectTimeout,
    this.receiveTimeout,
    this.enableLogger = false,
    this.getToken,
    this.onUnauthorized,
    this.interceptors,
    this.defaultHeaders,
    this.validateSsl = true,
    this.followRedirects = true,
    this.maxRedirects = 5,
  });

  /// Cria uma cópia com valores atualizados
  HttpClientConfig copyWith({
    String? baseUrl,
    Duration? timeout,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    bool? enableLogger,
    String Function()? getToken,
    Future<void> Function()? onUnauthorized,
    List<dynamic>? interceptors,
    Map<String, String>? defaultHeaders,
    bool? validateSsl,
    bool? followRedirects,
    int? maxRedirects,
  }) {
    return HttpClientConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      timeout: timeout ?? this.timeout,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      enableLogger: enableLogger ?? this.enableLogger,
      getToken: getToken ?? this.getToken,
      onUnauthorized: onUnauthorized ?? this.onUnauthorized,
      interceptors: interceptors ?? this.interceptors,
      defaultHeaders: defaultHeaders ?? this.defaultHeaders,
      validateSsl: validateSsl ?? this.validateSsl,
      followRedirects: followRedirects ?? this.followRedirects,
      maxRedirects: maxRedirects ?? this.maxRedirects,
    );
  }

  @override
  String toString() {
    return 'HttpClientConfig(baseUrl: $baseUrl, timeout: $timeout, enableLogger: $enableLogger)';
  }
}
