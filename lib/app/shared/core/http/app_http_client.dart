import 'http_request_config.dart';
import 'http_response.dart';

/// Interface abstrata do cliente HTTP
///
/// Define o contrato para implementações de clientes HTTP.
/// Facilita testes através de mocks e permite trocar a implementação
/// (Dio, http, etc.) sem afetar o código que usa o cliente.
///
/// Exemplo de uso:
/// ```dart
/// final client = DioHttpClientImpl(config);
/// final response = await client.get('/users');
/// print(response.body);
/// ```
abstract class AppHttpClient {
  /// Realiza uma requisição GET
  ///
  /// [url] - Endpoint da requisição (será concatenado com baseUrl)
  /// [config] - Configuração opcional para esta requisição específica
  ///
  /// Retorna [HttpResponse] com o body parseado
  Future<HttpResponse> get(
    String url, {
    HttpRequestConfig? config,
  });

  /// Realiza uma requisição POST
  ///
  /// [url] - Endpoint da requisição
  /// [data] - Dados a serem enviados no body (será serializado para JSON)
  /// [config] - Configuração opcional para esta requisição
  Future<HttpResponse> post(
    String url, {
    dynamic data,
    HttpRequestConfig? config,
  });

  /// Realiza uma requisição PUT
  ///
  /// [url] - Endpoint da requisição
  /// [data] - Dados a serem enviados no body
  /// [config] - Configuração opcional para esta requisição
  Future<HttpResponse> put(
    String url, {
    dynamic data,
    HttpRequestConfig? config,
  });

  /// Realiza uma requisição PATCH
  ///
  /// [url] - Endpoint da requisição
  /// [data] - Dados a serem enviados no body
  /// [config] - Configuração opcional para esta requisição
  Future<HttpResponse> patch(
    String url, {
    dynamic data,
    HttpRequestConfig? config,
  });

  /// Realiza uma requisição DELETE
  ///
  /// [url] - Endpoint da requisição
  /// [data] - Dados opcionais a serem enviados no body
  /// [config] - Configuração opcional para esta requisição
  Future<HttpResponse> delete(
    String url, {
    dynamic data,
    HttpRequestConfig? config,
  });

  /// Realiza uma requisição HEAD
  ///
  /// Retorna apenas os headers da resposta, sem o body
  /// Útil para verificar se um recurso existe sem baixá-lo
  Future<HttpResponse> head(
    String url, {
    HttpRequestConfig? config,
  });

  /// Realiza uma requisição OPTIONS
  ///
  /// Retorna os métodos HTTP permitidos para o recurso
  Future<HttpResponse> options(
    String url, {
    HttpRequestConfig? config,
  });

  /// Faz download de um arquivo
  ///
  /// [url] - URL do arquivo a ser baixado
  /// [savePath] - Caminho local onde o arquivo será salvo
  /// [cancelToken] - Token para cancelar o download
  /// [config] - Configuração opcional (útil para receiveProgress)
  ///
  /// Exemplo:
  /// ```dart
  /// final cancel = CancelDownload();
  /// final response = await client.download(
  ///   '/files/document.pdf',
  ///   '/storage/document.pdf',
  ///   cancelToken: cancel,
  ///   config: HttpRequestConfig(
  ///     receiveProgress: (received, total) {
  ///       print('${(received / total * 100).toStringAsFixed(0)}%');
  ///     },
  ///   ),
  /// );
  ///
  /// // Para cancelar:
  /// cancel.cancel();
  /// ```
  Future<DownloadHttpResponse> download(
    String url,
    String savePath, {
    CancelDownload? cancelToken,
    HttpRequestConfig? config,
  });

  /// Realiza uma requisição GET retornando bytes
  ///
  /// Útil para downloads de arquivos pequenos que serão mantidos em memória.
  /// Para arquivos grandes, prefira o método [download].
  ///
  /// [url] - URL do arquivo
  /// [config] - Configuração opcional (token, timeout, etc.)
  ///
  /// Retorna [List<int>] com os bytes do arquivo
  Future<List<int>> getBytes(
    String url, {
    HttpRequestConfig? config,
  });

  /// Envia um arquivo via multipart/form-data
  ///
  /// [url] - Endpoint da requisição
  /// [filePath] - Caminho absoluto do arquivo no dispositivo
  /// [fileField] - Nome do campo do arquivo no form (ex: 'avatar', 'logo')
  /// [config] - Configuração opcional (token, timeout, etc.)
  Future<HttpResponse> uploadFile(
    String url, {
    required String filePath,
    required String fileField,
    HttpRequestConfig? config,
  });
}
