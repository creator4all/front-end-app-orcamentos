/// Tipos de resposta HTTP suportados
enum HttpResponseType {
  /// Resposta JSON (padrão) - será parseado automaticamente
  json,

  /// Texto puro (String)
  plain,

  /// Bytes (List<int>) - para arquivos binários
  bytes,

  /// Stream de bytes - para uploads/downloads grandes
  stream,
}

/// Configuração específica para uma requisição HTTP
///
/// Permite sobrescrever configurações globais do cliente para requests específicos
class HttpRequestConfig {
  /// Headers customizados para esta requisição
  final Map<String, dynamic>? headers;

  /// Content-Type customizado (padrão: application/json)
  final String? contentType;

  /// Token de autenticação específico para esta requisição
  final String? token;

  /// Timeout específico para esta requisição
  final Duration? timeout;

  final Duration? connectTimeout;

  /// BaseUrl customizada (sobrescreve a global)
  final String? baseUrl;

  /// Tipo de resposta esperado
  final HttpResponseType? responseType;

  /// Callback de progresso de envio (para uploads)
  /// Recebe (bytes enviados, total de bytes)
  final Function(int sent, int total)? sendProgress;

  /// Callback de progresso de recebimento (para downloads)
  /// Recebe (bytes recebidos, total de bytes)
  final Function(int received, int total)? receiveProgress;

  /// Validar certificados SSL (padrão: true)
  final bool? validateSsl;

  /// Query parameters customizados
  final Map<String, dynamic>? queryParameters;

  HttpRequestConfig({
    this.headers,
    this.contentType,
    this.token,
    this.timeout,
    this.connectTimeout,
    this.baseUrl,
    this.responseType,
    this.sendProgress,
    this.receiveProgress,
    this.validateSsl,
    this.queryParameters,
  });

  /// Cria uma cópia com valores atualizados
  HttpRequestConfig copyWith({
    Map<String, dynamic>? headers,
    String? contentType,
    String? token,
    Duration? timeout,
    Duration? connectTimeout,
    String? baseUrl,
    HttpResponseType? responseType,
    Function(int, int)? sendProgress,
    Function(int, int)? receiveProgress,
    bool? validateSsl,
    Map<String, dynamic>? queryParameters,
  }) {
    return HttpRequestConfig(
      headers: headers ?? this.headers,
      contentType: contentType ?? this.contentType,
      token: token ?? this.token,
      timeout: timeout ?? this.timeout,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      baseUrl: baseUrl ?? this.baseUrl,
      responseType: responseType ?? this.responseType,
      sendProgress: sendProgress ?? this.sendProgress,
      receiveProgress: receiveProgress ?? this.receiveProgress,
      validateSsl: validateSsl ?? this.validateSsl,
      queryParameters: queryParameters ?? this.queryParameters,
    );
  }

  @override
  String toString() {
    return 'HttpRequestConfig(timeout: $timeout, contentType: $contentType, responseType: $responseType)';
  }
}
