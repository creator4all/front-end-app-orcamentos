import 'api_service.dart';
import '../config/api_config.dart';
import '../entities/estado_entity.dart';
import '../entities/cidade_entity.dart';

class GeoService {
  final ApiService _api;
  GeoService({ApiService? api}) : _api = api ?? ApiService();

  Future<List<EstadoEntity>> listarEstados() async {
    final res = await _api.get(ApiConfig.estadosEndpoint);
    if (res['success'] == true) {
      final data = (res['data']['dados'] as List);
      return data
          .map((e) => EstadoEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(res['error'] ?? 'Falha ao carregar estados');
  }

  Future<List<CidadeEntity>> listarCidades({int? estadoId}) async {
    final endpoint = estadoId == null
        ? ApiConfig.cidadesEndpoint
        : '${ApiConfig.cidadesEndpoint}/estado/$estadoId';
    final res = await _api.get(endpoint);
    if (res['success'] == true) {
      final data = (res['data']['dados'] as List);
      final list = data
          .map((e) => CidadeEntity.fromJson(e as Map<String, dynamic>))
          .toList();
      if (estadoId == null) return list;
      return list.where((c) => c.estadoId == estadoId).toList();
    }
    throw Exception(res['error'] ?? 'Falha ao carregar cidades');
  }
}
