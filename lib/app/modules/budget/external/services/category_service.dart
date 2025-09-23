import 'package:multimidiaapp/services/api_service.dart';
import '../../domain/models/category.dart';

class CategoryService {
  final ApiService _api;
  CategoryService(this._api);

  Future<List<CategoryDto>> listar() async {
    final res = await _api.get('/api/categorias');
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
        .map((e) => CategoryDto.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
