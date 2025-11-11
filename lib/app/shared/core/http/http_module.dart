import 'package:flutter_modular/flutter_modular.dart';

import '../../../../config/api_config.dart';
import '../utils/token_cache.dart';
import 'app_http_client.dart';
import 'dio_config_factory.dart';
import 'dio_http_client_impl.dart';
import 'http_client_config.dart';

/// Módulo para injeção de dependências do HTTP Client
///
/// Registra todas as dependências necessárias para usar o cliente HTTP.
///
/// Para usar, adicione no seu AppModule:
/// ```dart
/// @override
/// List<Module> get imports => [
///   HttpModule(),
/// ];
/// ```
class HttpModule extends Module {
  @override
  List<Bind> get binds => [
        // Configuração do cliente HTTP
        Bind<HttpClientConfig>(
          (i) => DioConfigFactory.createDefault(
            baseUrl: ApiConfig.baseUrl,
            getToken: () => TokenCache.instance.getTokenOrEmpty(),
            enableLogger: _isDebugMode(),
          ),
          isSingleton: true,
        ),

        // Cliente HTTP (implementação concreta)
        Bind<AppHttpClient>(
          (i) => DioHttpClientImpl(i.get<HttpClientConfig>()),
          isSingleton: true,
        ),
      ];

  /// Verifica se está em modo debug
  bool _isDebugMode() {
    // Em modo debug, habilita logger
    bool isDebug = false;
    assert(isDebug = true);
    return isDebug;
  }
}
