import '../http_response.dart';

/// Interface base para interceptadores HTTP
///
/// Interceptadores permitem modificar requisições antes de serem enviadas
/// e processar respostas antes de serem retornadas ao código que chamou.
///
/// Exemplo de uso:
/// ```dart
/// class MyInterceptor extends HttpInterceptor {
///   @override
///   void onRequest(HttpRequestInfo request) {
///     print('Fazendo request para: ${request.url}');
///   }
///
///   @override
///   void onResponse(HttpResponseBase response) {
///     print('Resposta recebida: ${response.statusCode}');
///   }
///
///   @override
///   Future<bool> onError(Exception error, HttpRequestInfo request) async {
///     if (error is TokenExpiredException) {
///       await refreshToken();
///       return true; // Retry a requisição
///     }
///     return false; // Não retry
///   }
/// }
/// ```
abstract class HttpInterceptor {
  /// Chamado antes da requisição ser enviada
  ///
  /// Permite modificar headers, dados, URL, etc.
  /// [request] - Informações da requisição que será enviada
  void onRequest(HttpRequestInfo request) {}

  /// Chamado quando a resposta é recebida com sucesso
  ///
  /// Permite processar ou modificar a resposta antes de retorná-la
  /// [response] - Resposta recebida do servidor
  void onResponse(HttpResponseBase response) {}

  /// Chamado quando ocorre um erro na requisição
  ///
  /// Permite tratar o erro e decidir se deve retentar a requisição
  /// [error] - Exceção que ocorreu
  /// [request] - Informações da requisição que falhou
  /// [responseMessage] - Mensagem da resposta de erro (se houver)
  /// [responsePayload] - Payload da resposta de erro (se houver)
  ///
  /// Retorna:
  /// - `true` se a requisição deve ser retentada automaticamente
  /// - `false` se o erro deve ser propagado
  Future<bool> onError(
    Exception error,
    HttpRequestInfo request,
    String responseMessage,
    String responsePayload,
  ) async {
    return false;
  }
}
