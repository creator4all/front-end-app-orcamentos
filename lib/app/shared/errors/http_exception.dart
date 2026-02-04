/// Exception HTTP com status code para mapeamento preciso de erros
///
/// Permite identificar erros de API pelo código HTTP ao invés de
/// depender de strings nas mensagens.
class HttpException implements Exception {
  final int statusCode;
  final String message;

  const HttpException({required this.statusCode, required this.message});

  bool get isUnauthorized => statusCode == 401 || statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isValidationError => statusCode == 422;
  bool get isServerError => statusCode >= 500;

  @override
  String toString() => 'HttpException($statusCode): $message';
}
