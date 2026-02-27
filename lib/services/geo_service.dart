import '../app/shared/core/http/app_http_client.dart';
import '../app/shared/core/http/http_request_config.dart';
import '../app/shared/core/utils/token_cache.dart';
import '../config/api_config.dart';
import '../entities/cidade_entity.dart';
import '../entities/estado_entity.dart';

class GeoService {
  final AppHttpClient _client;

  GeoService({required AppHttpClient client}) : _client = client;

  Future<List<EstadoEntity>> listarEstados() async {
    final token = TokenCache.instance.getTokenOrEmpty();
    final response = await _client.get(
      ApiConfig.estadosEndpoint,
      config: HttpRequestConfig(token: token),
    );

    if (response.isSuccess) {
      final data = (response.body['dados'] as List);
      return data
          .map((e) => EstadoEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(response.body['error'] ?? 'Falha ao carregar estados');
  }

  Future<List<CidadeEntity>> listarCidades({int? estadoId}) async {
    final token = TokenCache.instance.getTokenOrEmpty();
    final endpoint = estadoId == null
        ? ApiConfig.cidadesEndpoint
        : '${ApiConfig.cidadesEndpoint}/estado/$estadoId';

    final response = await _client.get(
      endpoint,
      config: HttpRequestConfig(token: token),
    );

    if (response.isSuccess) {
      final data = (response.body['dados'] as List);
      final list = data
          .map((e) => CidadeEntity.fromJson(e as Map<String, dynamic>))
          .toList();
      if (estadoId == null) return list;
      return list.where((c) => c.estadoId == estadoId).toList();
    }
    throw Exception(response.body['error'] ?? 'Falha ao carregar cidades');
  }
}
