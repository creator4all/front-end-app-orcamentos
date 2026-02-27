import 'app_error.dart';

/// Exceções específicas para erros HTTP

/// Erro HTTP genérico
class HttpException extends AppError {
  final int? statusCode;
  final String? endpoint;
  final dynamic requestData;

  const HttpException({
    required super.message,
    this.statusCode,
    this.endpoint,
    this.requestData,
    super.data,
    super.stackTrace,
  });

  @override
  String toString() {
    return 'HttpException [$statusCode]: $message${endpoint != null ? ' - Endpoint: $endpoint' : ''}';
  }
}

/// Erro 400 - Bad Request
class BadRequestException extends HttpException {
  const BadRequestException({
    super.message = 'Requisição inválida',
    super.endpoint,
    super.requestData,
    super.data,
  }) : super(
          statusCode: 400,
        );
}

/// Erro 401 - Unauthorized
class UnauthorizedException extends HttpException {
  const UnauthorizedException({
    super.message = 'Não autorizado. Faça login novamente',
    super.endpoint,
  }) : super(
          statusCode: 401,
        );

  @override
  bool get shouldReportToDevelopers => false;
}

/// Erro 403 - Forbidden
class ForbiddenException extends HttpException {
  const ForbiddenException({
    super.message = 'Acesso negado',
    super.endpoint,
  }) : super(
          statusCode: 403,
        );
}

/// Erro 404 - Not Found
class NotFoundException extends HttpException {
  const NotFoundException({
    super.message = 'Recurso não encontrado',
    super.endpoint,
  }) : super(
          statusCode: 404,
        );

  @override
  bool get shouldReportToDevelopers => false;
}

/// Erro 408 - Request Timeout
class TimeoutException extends HttpException {
  const TimeoutException({
    super.message = 'Tempo de requisição esgotado',
    super.endpoint,
  }) : super(
          statusCode: 408,
        );

  @override
  bool get shouldReportToDevelopers => false;
}

/// Erro 422 - Unprocessable Entity
class UnprocessableEntityException extends HttpException {
  final Map<String, dynamic>? validationErrors;

  const UnprocessableEntityException({
    super.message = 'Dados inválidos',
    super.endpoint,
    this.validationErrors,
  }) : super(
          statusCode: 422,
          data: validationErrors,
        );
}

/// Erro 426 - Upgrade Required
class UpgradeRequiredException extends HttpException {
  const UpgradeRequiredException({
    super.message = 'Atualização do aplicativo necessária',
    super.endpoint,
  }) : super(
          statusCode: 426,
        );

  @override
  bool get shouldReportToDevelopers => false;
}

/// Erro 429 - Too Many Requests
class TooManyRequestsException extends HttpException {
  final int? retryAfterSeconds;

  const TooManyRequestsException({
    super.message = 'Muitas requisições. Tente novamente mais tarde',
    super.endpoint,
    this.retryAfterSeconds,
  }) : super(
          statusCode: 429,
          data: retryAfterSeconds,
        );
}

/// Erro 500 - Internal Server Error
class InternalServerException extends HttpException {
  const InternalServerException({
    super.message = 'Erro interno do servidor',
    super.endpoint,
    super.data,
  }) : super(
          statusCode: 500,
        );

  @override
  bool get shouldReportToDevelopers => true;
}

/// Erro 502 - Bad Gateway
class BadGatewayException extends HttpException {
  const BadGatewayException({
    super.message = 'Servidor temporariamente indisponível',
    super.endpoint,
  }) : super(
          statusCode: 502,
        );
}

/// Erro 503 - Service Unavailable
class ServiceUnavailableException extends HttpException {
  const ServiceUnavailableException({
    super.message = 'Serviço temporariamente indisponível',
    super.endpoint,
  }) : super(
          statusCode: 503,
        );
}

/// Erro 504 - Gateway Timeout
class GatewayTimeoutException extends HttpException {
  const GatewayTimeoutException({
    super.message = 'Tempo de resposta do servidor esgotado',
    super.endpoint,
  }) : super(
          statusCode: 504,
        );
}

/// Erro de conexão (sem internet, DNS falhou, etc)
class ConnectionException extends HttpException {
  const ConnectionException({
    super.message = 'Erro de conexão. Verifique sua internet',
    super.endpoint,
    super.data,
  });

  @override
  bool get shouldReportToDevelopers => false;
}

/// Erro de cancelamento de requisição
class CancelledException extends HttpException {
  const CancelledException({
    super.message = 'Requisição cancelada',
    super.endpoint,
  });

  @override
  bool get shouldReportToDevelopers => false;
}

/// Factory para criar exceções baseado no status code
class HttpExceptionFactory {
  static HttpException fromStatusCode({
    required int statusCode,
    String? message,
    String? endpoint,
    dynamic data,
  }) {
    switch (statusCode) {
      case 400:
        return BadRequestException(
          message: message ?? 'Requisição inválida',
          endpoint: endpoint,
          data: data,
        );
      case 401:
        return UnauthorizedException(
          message: message ?? 'Não autorizado',
          endpoint: endpoint,
        );
      case 403:
        return ForbiddenException(
          message: message ?? 'Acesso negado',
          endpoint: endpoint,
        );
      case 404:
        return NotFoundException(
          message: message ?? 'Recurso não encontrado',
          endpoint: endpoint,
        );
      case 408:
        return TimeoutException(
          message: message ?? 'Tempo esgotado',
          endpoint: endpoint,
        );
      case 422:
        return UnprocessableEntityException(
          message: message ?? 'Dados inválidos',
          endpoint: endpoint,
          validationErrors: data is Map<String, dynamic> ? data : null,
        );
      case 426:
        return UpgradeRequiredException(
          message: message ?? 'Atualização necessária',
          endpoint: endpoint,
        );
      case 429:
        return TooManyRequestsException(
          message: message ?? 'Muitas requisições',
          endpoint: endpoint,
        );
      case 500:
        return InternalServerException(
          message: message ?? 'Erro do servidor',
          endpoint: endpoint,
          data: data,
        );
      case 502:
        return BadGatewayException(
          message: message ?? 'Servidor indisponível',
          endpoint: endpoint,
        );
      case 503:
        return ServiceUnavailableException(
          message: message ?? 'Serviço indisponível',
          endpoint: endpoint,
        );
      case 504:
        return GatewayTimeoutException(
          message: message ?? 'Timeout do servidor',
          endpoint: endpoint,
        );
      default:
        return HttpException(
          message: message ?? 'Erro HTTP',
          statusCode: statusCode,
          endpoint: endpoint,
          data: data,
        );
    }
  }
}
