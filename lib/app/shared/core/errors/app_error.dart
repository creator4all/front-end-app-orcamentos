/// Exceção base da aplicação
///
/// Todas as exceções customizadas devem estender desta classe
/// para facilitar o tratamento de erros centralizado.
class AppError implements Exception {
  final String message;
  final dynamic data;
  final bool isFatal;
  final StackTrace? stackTrace;

  /// Indica se este erro deve ser reportado aos desenvolvedores
  /// (ex: Sentry, Firebase Crashlytics)
  bool get shouldReportToDevelopers => false;

  const AppError({
    required this.message,
    this.data,
    this.isFatal = false,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'AppError: $message';
  }
}

/// Erro de internet/conectividade
class AppInternetError extends AppError {
  const AppInternetError([
    String message = 'Sem conexão com a internet',
  ]) : super(message: message);

  @override
  bool get shouldReportToDevelopers => false;
}

/// Erro de armazenamento insuficiente
class AppStorageError extends AppError {
  const AppStorageError([
    String message = 'Espaço de armazenamento insuficiente',
  ]) : super(message: message, isFatal: true);
}

/// Erro de permissão negada
class AppPermissionError extends AppError {
  final String permission;

  const AppPermissionError({
    required this.permission,
    super.message = 'Permissão negada',
  }) : super(data: permission);
}

/// Erro de validação de dados
class AppValidationError extends AppError {
  final Map<String, String>? errors;

  const AppValidationError({
    required super.message,
    this.errors,
  }) : super(data: errors);
}

/// Erro desconhecido que deve ser reportado
class AppUnknownError extends AppError {
  const AppUnknownError({
    super.message = 'Erro desconhecido',
    super.data,
    super.stackTrace,
  }) : super(
          isFatal: true,
        );

  @override
  bool get shouldReportToDevelopers => true;
}
