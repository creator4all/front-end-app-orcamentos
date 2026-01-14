import '../../../../../shared/core/http/app_http_client.dart';
import '../models/category_dto.dart';
import '../models/indicator_group_dto.dart';
import '../models/product_config_dto.dart';
import '../models/subcategory_dto.dart';
import 'product_config_datasource.dart';

/// Implementação do datasource usando API
class ProductConfigApiDatasource implements ProductConfigDatasource {
  final AppHttpClient httpClient;

  ProductConfigApiDatasource({required this.httpClient});

  @override
  Future<List<CategoryDto>> getCategories() async {
    final response = await httpClient.get('/api/categorias');
    final dadosList = response.body['dados'] as List<dynamic>? ?? [];

    return dadosList
        .map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SubcategoryDto>> getSubcategories(int categoryId) async {
    final response =
        await httpClient.get('/api/subcategorias/categoria/$categoryId');
    final dadosList = response.body['dados'] as List<dynamic>? ?? [];

    return dadosList
        .map((e) => SubcategoryDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ProductConfigDto>> getProducts(int subcategoryId) async {
    final response =
        await httpClient.get('/api/produtos/subcategoria/$subcategoryId');
    final dadosList = response.body['dados'] as List<dynamic>? ?? [];

    return dadosList
        .map((e) => ProductConfigDto.fromListJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProductConfigDto> getProductDetails(int productId) async {
    final response = await httpClient.get('/api/produtos/$productId');
    final dados = response.body['dados'] as Map<String, dynamic>;

    return ProductConfigDto.fromDetailJson(dados);
  }

  @override
  Future<ProductConfigDto> updateProduct(
      int productId, Map<String, dynamic> data) async {
    final response = await httpClient.put(
      '/api/produtos/$productId',
      data: data,
    );
    final dados = response.body['dados'] as Map<String, dynamic>;

    // Resposta do PUT usa formato de lista
    return ProductConfigDto.fromListJson(dados);
  }

  @override
  Future<List<IndicatorGroupDto>> getIndicators() async {
    final response = await httpClient.get('/api/indicadores-etapa');
    final dataList = response.body['data'] as List<dynamic>? ?? [];

    return dataList
        .map((e) => IndicatorGroupDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateProductStatus(int productId, bool status) async {
    await httpClient.patch(
      '/api/produtos/$productId',
      data: {'pro_status': status},
    );
  }
}
