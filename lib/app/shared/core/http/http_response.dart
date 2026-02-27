/// Informações da requisição HTTP para debug e logs
class HttpRequestInfo {
  final String method;
  final String url;
  final dynamic data;
  final Map<String, dynamic> headers;
  final Duration? timeout;

  HttpRequestInfo({
    required this.method,
    required this.url,
    this.data,
    required this.headers,
    this.timeout,
  });

  @override
  String toString() {
    return 'HttpRequestInfo(method: $method, url: $url, headers: $headers)';
  }
}

/// Classe base para todas as respostas HTTP
abstract class HttpResponseBase {
  final Map<String, List<String>> headers;
  final int? statusCode;
  final String? statusMessage;
  final HttpRequestInfo? requestInfo;

  HttpResponseBase({
    required this.headers,
    this.statusCode,
    this.statusMessage,
    this.requestInfo,
  });

  bool get isSuccess =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;

  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  bool get isServerError =>
      statusCode != null && statusCode! >= 500 && statusCode! < 600;
}

/// Resposta HTTP padrão com body em Map (JSON)
class HttpResponse extends HttpResponseBase {
  final Map<String, dynamic> body;

  HttpResponse({
    required this.body,
    required super.headers,
    super.statusCode,
    super.statusMessage,
    super.requestInfo,
  });

  @override
  String toString() {
    return 'HttpResponse(statusCode: $statusCode, body: $body)';
  }

  /// Cria uma cópia com valores atualizados
  HttpResponse copyWith({
    Map<String, dynamic>? body,
    Map<String, List<String>>? headers,
    int? statusCode,
    String? statusMessage,
    HttpRequestInfo? requestInfo,
  }) {
    return HttpResponse(
      body: body ?? this.body,
      headers: headers ?? this.headers,
      statusCode: statusCode ?? this.statusCode,
      statusMessage: statusMessage ?? this.statusMessage,
      requestInfo: requestInfo ?? this.requestInfo,
    );
  }
}

/// Resposta de download com bytes e path do arquivo
class DownloadHttpResponse extends HttpResponseBase {
  final List<int> bytes;
  final String? filePath;

  DownloadHttpResponse({
    required this.bytes,
    this.filePath,
    required super.headers,
    super.statusCode,
    super.statusMessage,
    super.requestInfo,
  });

  int get sizeInBytes => bytes.length;

  double get sizeInMB => bytes.length / (1024 * 1024);

  @override
  String toString() {
    return 'DownloadHttpResponse(statusCode: $statusCode, sizeInMB: ${sizeInMB.toStringAsFixed(2)}MB, filePath: $filePath)';
  }
}

/// Classe para controlar cancelamento de downloads
class CancelDownload {
  Function? _callback;
  bool isCanceled = false;

  /// Registra callback a ser chamado quando cancelar
  void subscribe(Function callback) {
    _callback = callback;
  }

  /// Cancela o download
  void cancel() {
    if (_callback != null) {
      isCanceled = true;
      _callback!();
    } else {
      throw Exception(
        'Solicitação de cancelamento recebida, mas não há listener registrado',
      );
    }
  }

  /// Reseta o estado de cancelamento
  void reset() {
    isCanceled = false;
  }
}
