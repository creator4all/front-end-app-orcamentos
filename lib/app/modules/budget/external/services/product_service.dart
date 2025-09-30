import 'package:multimidiaapp/services/api_service.dart';
import '../../domain/models/product.dart';

class ProductService {
  final ApiService _api;
  ProductService(this._api);

  Future<List<ProductDto>> listarPorSubcategoria(int subcategoriaId) async {
    final res = await _api.get('/api/produtos/subcategoria/$subcategoriaId');
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
        .map((e) {
          // Ensure each product has the correct subcategory ID
          final Map<String, dynamic> productMap = Map<String, dynamic>.from(e as Map);
          // Add or update the subcategory ID if not present
          if (!productMap.containsKey('pro_subcategoria_id')) {
            productMap['pro_subcategoria_id'] = subcategoriaId;
          }
          return ProductDto.fromJson(productMap);
        })
        .toList();
  }
}
