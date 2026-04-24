import '../constants/http_constants.dart';
import 'http_client_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/http_interceptor.dart';
import 'interceptors/version_checker_interceptor.dart';

class DioConfigFactory {
  static HttpClientConfig createDefault({
    required String baseUrl,
    String Function()? getToken,
    Future<void> Function()? onUnauthorized,
    bool enableLogger = false,
    Duration? timeout,
    List<HttpInterceptor>? additionalInterceptors,
    Map<String, String>? defaultHeaders,
  }) {
    final interceptors = <HttpInterceptor>[
      if (getToken != null)
        AuthInterceptor(
          getToken: getToken,
          excludedPaths: ['/login', '/register', '/refresh-token'],
        ),
      ...?additionalInterceptors,
    ];

    return HttpClientConfig(
      baseUrl: baseUrl,
      timeout: timeout ?? HttpTimeouts.defaultTimeout,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: timeout ?? HttpTimeouts.defaultTimeout,
      enableLogger: enableLogger,
      getToken: getToken,
      onUnauthorized: onUnauthorized,
      interceptors: interceptors,
      defaultHeaders: defaultHeaders,
      validateSsl: true,
      followRedirects: true,
      maxRedirects: 5,
    );
  }

  static HttpClientConfig createForDevelopment({
    required String baseUrl,
    String Function()? getToken,
    Future<void> Function()? onUnauthorized,
    bool validateSsl = false,
    List<HttpInterceptor>? additionalInterceptors,
  }) {
    return createDefault(
      baseUrl: baseUrl,
      getToken: getToken,
      onUnauthorized: onUnauthorized,
      enableLogger: true,
      timeout: HttpTimeouts.longTimeout,
      additionalInterceptors: additionalInterceptors,
      defaultHeaders: {
        'X-Environment': 'development',
      },
    ).copyWith(validateSsl: validateSsl);
  }

  static HttpClientConfig createForProduction({
    required String baseUrl,
    required String appVersion,
    String Function()? getToken,
    Future<void> Function()? onUnauthorized,
    Function(dynamic)? onUpdateRequired,
    List<HttpInterceptor>? additionalInterceptors,
  }) {
    final interceptors = <HttpInterceptor>[
      VersionCheckerInterceptor(
        currentVersion: appVersion,
        onUpdateRequired: onUpdateRequired,
      ),
      ...?additionalInterceptors,
    ];

    return createDefault(
      baseUrl: baseUrl,
      getToken: getToken,
      onUnauthorized: onUnauthorized,
      enableLogger: false,
      timeout: HttpTimeouts.defaultTimeout,
      additionalInterceptors: interceptors,
      defaultHeaders: {
        'X-Environment': 'production',
        'X-App-Version': appVersion,
      },
    );
  }

  static HttpClientConfig createForTesting({
    required String baseUrl,
    String Function()? getToken,
    Future<void> Function()? onUnauthorized,
    List<HttpInterceptor>? interceptors,
  }) {
    return HttpClientConfig(
      baseUrl: baseUrl,
      timeout: HttpTimeouts.shortTimeout,
      connectTimeout: HttpTimeouts.shortTimeout,
      receiveTimeout: HttpTimeouts.shortTimeout,
      enableLogger: false,
      getToken: getToken,
      onUnauthorized: onUnauthorized,
      interceptors: interceptors,
      validateSsl: false,
    );
  }

  static HttpClientConfig createCustom({
    required String baseUrl,
    Duration? timeout,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    bool enableLogger = false,
    String Function()? getToken,
    Future<void> Function()? onUnauthorized,
    List<HttpInterceptor>? interceptors,
    Map<String, String>? defaultHeaders,
    bool validateSsl = true,
    bool followRedirects = true,
    int maxRedirects = 5,
  }) {
    return HttpClientConfig(
      baseUrl: baseUrl,
      timeout: timeout ?? HttpTimeouts.defaultTimeout,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      enableLogger: enableLogger,
      getToken: getToken,
      onUnauthorized: onUnauthorized,
      interceptors: interceptors,
      defaultHeaders: defaultHeaders,
      validateSsl: validateSsl,
      followRedirects: followRedirects,
      maxRedirects: maxRedirects,
    );
  }
}
