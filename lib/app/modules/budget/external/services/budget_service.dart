import 'package:multimidiaapp/services/api_service.dart';
import '../../domain/models/budget_summary.dart';
import '../../domain/models/budget_create.dart';

class BudgetService {
  final ApiService _api;
  BudgetService(this._api);

  Future<List<BudgetSummaryDto>> listar({String? status}) async {
    final res = await _api.get('/api/orcamentos${status != null ? '?orc_status=$status' : ''}');
    final data = res is Map<String, dynamic> ? (res['dados'] ?? res['data'] ?? res) : res;
    final List list;
    if (data is Map && data['dados'] is List) {
      list = data['dados'] as List;
    } else if (data is List) {
      list = data;
    } else {
      list = [];
    }
    return list.map((e) => BudgetSummaryDto.fromMap(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<Map<String, dynamic>> criar(BudgetCreateDto dto) async {
    final res = await _api.post('/api/orcamentos', dto.toMap());
    final data = res is Map<String, dynamic> ? (res['dados'] ?? res['data'] ?? res) : res;
    return Map<String, dynamic>.from(data as Map);
  }
}
