/// Barrel file para exportar todo o core HTTP
///
/// Permite importar tudo de uma vez:
/// ```dart
/// import 'app/shared/core/http/http.dart';
/// ```
library;

// Interfaces e abstrações
export 'app_http_client.dart';
export 'dio_config_factory.dart';
// Implementações
export 'dio_http_client_impl.dart';
export 'extensions/dio_request_options_extension.dart';
// Extensions
export 'extensions/dio_response_extension.dart';
export 'http_client_config.dart';
// Módulo de DI
export 'http_module.dart';
export 'http_request_config.dart';
export 'http_response.dart';
// Interceptors
export 'interceptors/interceptors.dart';
