import 'app_error.dart';
import 'http_exceptions.dart';

/// Traduz um erro de requisição na mensagem que a API realmente devolveu.
///
/// Sem isso o usuário recebe sempre um texto genérico e não descobre qual
/// campo precisa corrigir — o webservice responde 422 com os erros por campo
/// em `erros` e 409 com a mensagem em `mensagem`.
class ApiErrorMessage {
  /// Mensagem para falhas do servidor, que podem carregar detalhes internos.
  static const String serverFailure =
      'O servidor não conseguiu processar a solicitação. Tente novamente em alguns instantes.';

  static String from(Object error, {required String fallback}) {
    if (error is! AppError) return fallback;

    if (error is HttpException) {
      final statusCode = error.statusCode;
      if (statusCode != null && statusCode >= 500) {
        return serverFailure;
      }
    }

    final payload = error.data;
    if (payload is Map) {
      final fieldErrors = _flatten(payload['erros'] ?? payload['errors']);
      if (fieldErrors.isNotEmpty) {
        return fieldErrors.join('\n');
      }

      final apiMessage = payload['mensagem'] ?? payload['message'];
      if (apiMessage is String && apiMessage.trim().isNotEmpty) {
        return _hideDatabaseDetails(apiMessage.trim());
      }
    }

    final message = error.message.trim();
    return message.isEmpty ? fallback : _hideDatabaseDetails(message);
  }

  /// O webservice também responde 4xx para alguns erros de banco (ex.: dado
  /// longo demais), repassando o SQL na mensagem.
  static String _hideDatabaseDetails(String message) {
    return message.contains('SQLSTATE') ? serverFailure : message;
  }

  /// O webservice aninha os erros como `{campo: {rotulo: mensagem}}`, então a
  /// varredura precisa descer até as folhas de texto.
  static List<String> _flatten(Object? errors) {
    final messages = <String>[];

    void visit(Object? node) {
      if (node is String) {
        final text = node.trim();
        if (text.isNotEmpty && !messages.contains(text)) {
          messages.add(text);
        }
        return;
      }
      if (node is Map) {
        node.values.forEach(visit);
        return;
      }
      if (node is List) {
        node.forEach(visit);
      }
    }

    visit(errors);
    return messages;
  }
}
