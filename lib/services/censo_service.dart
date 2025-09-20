import 'api_service.dart';
import '../config/api_config.dart';
import '../entities/censo_entity.dart';

class CensoService {
  final ApiService _api;
  CensoService({ApiService? api}) : _api = api ?? ApiService();

  Future<CensoData> listarGruposCenso() async {
    final res = await _api.get(ApiConfig.gruposCensoEndpoint);
    if (res['success'] == true) {
      final data = res['data'];
      if (data is Map<String, dynamic>) {
        return CensoData.fromJson(data);
      }
      if (data is List) {
        return CensoData(
            totalStudents: 0,
            censusYear: '',
            groups: data
                .map((e) => CensoGroup.fromJson(e as Map<String, dynamic>))
                .toList());
      }
    }
    throw Exception(res['error'] ?? 'Falha ao carregar grupos do censo');
  }

  Future<CensoData> censoPorCidade(int cidadeId) async {
    final res = await _api.get(ApiConfig.censoPorCidadeEndpoint(cidadeId));
    if (res['success'] == true) {
      final data = res['data'] as Map<String, dynamic>;
      return CensoData.fromJson(data);
    }
    throw Exception(res['error'] ?? 'Falha ao carregar censo por cidade');
  }
}
