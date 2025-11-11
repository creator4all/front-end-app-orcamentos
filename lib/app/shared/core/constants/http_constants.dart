/// Constantes relacionadas a HTTP
library;

/// Timeouts padrão
class HttpTimeouts {
  static const defaultTimeout = Duration(seconds: 30);
  static const shortTimeout = Duration(seconds: 10);
  static const longTimeout = Duration(minutes: 2);
  static const downloadTimeout = Duration(minutes: 5);
}

/// Content Types comuns
class ContentTypes {
  static const json = 'application/json';
  static const formUrlEncoded = 'application/x-www-form-urlencoded';
  static const formData = 'multipart/form-data';
  static const pdf = 'application/pdf';
  static const xml = 'application/xml';
  static const textPlain = 'text/plain';
  static const textHtml = 'text/html';
}

/// Status codes HTTP comuns
class HttpStatusCodes {
  // Success
  static const ok = 200;
  static const created = 201;
  static const accepted = 202;
  static const noContent = 204;

  // Client Errors
  static const badRequest = 400;
  static const unauthorized = 401;
  static const forbidden = 403;
  static const notFound = 404;
  static const methodNotAllowed = 405;
  static const requestTimeout = 408;
  static const conflict = 409;
  static const unprocessableEntity = 422;
  static const upgradeRequired = 426;
  static const tooManyRequests = 429;

  // Server Errors
  static const internalServerError = 500;
  static const notImplemented = 501;
  static const badGateway = 502;
  static const serviceUnavailable = 503;
  static const gatewayTimeout = 504;

  /// Verifica se é código de sucesso (2xx)
  static bool isSuccess(int code) => code >= 200 && code < 300;

  /// Verifica se é erro do cliente (4xx)
  static bool isClientError(int code) => code >= 400 && code < 500;

  /// Verifica se é erro do servidor (5xx)
  static bool isServerError(int code) => code >= 500 && code < 600;
}

/// Headers HTTP comuns
class HttpHeaders {
  static const authorization = 'Authorization';
  static const contentType = 'Content-Type';
  static const accept = 'Accept';
  static const userAgent = 'User-Agent';
  static const acceptLanguage = 'Accept-Language';
  static const cacheControl = 'Cache-Control';
  static const contentLength = 'Content-Length';
  static const etag = 'ETag';
  static const ifNoneMatch = 'If-None-Match';
  static const xRequestedWith = 'X-Requested-With';
  static const xApiKey = 'X-API-Key';
  static const xAppVersion = 'X-App-Version';
  static const xDeviceId = 'X-Device-Id';
  static const xPlatform = 'X-Platform';
}

/// Métodos HTTP
class HttpMethods {
  static const get = 'GET';
  static const post = 'POST';
  static const put = 'PUT';
  static const patch = 'PATCH';
  static const delete = 'DELETE';
  static const head = 'HEAD';
  static const options = 'OPTIONS';
}
