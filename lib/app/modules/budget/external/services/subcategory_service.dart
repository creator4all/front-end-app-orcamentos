import 'package:multimidiaapp/services/api_service.dart';
import '../../domain/models/subcategory.dart';

class SubcategoryService {
  final ApiService _api;
  SubcategoryService(this._api);

  Future<List<SubcategoryDto>> listarPorCategoria(int categoriaId) async {
    final res = await _api.get('/api/subcategorias/categoria/$categoriaId');
    final data = res is Map<String, dynamic>
        ? (res['data'] ?? res['dados'] ?? res)
        : res;
    final List list;
    if (data is Map && data['dados'] is List) {
      list = data['dados'] as List;
    } else if (data is List) {
      list = data;
    } else {
      list = [];
    }
    return list
        .map(
            (e) => SubcategoryDto.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
