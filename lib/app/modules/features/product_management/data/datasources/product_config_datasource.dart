import '../models/category_dto.dart';
import '../models/indicator_group_dto.dart';
import '../models/product_config_dto.dart';
import '../models/subcategory_dto.dart';

/// Interface abstrata do datasource de configuração de produtos
abstract class ProductConfigDatasource {
  /// Obtém todas as categorias
  Future<List<CategoryDto>> getCategories();

  /// Obtém subcategorias de uma categoria específica
  Future<List<SubcategoryDto>> getSubcategories(int categoryId);

  /// Obtém produtos de uma subcategoria específica
  Future<List<ProductConfigDto>> getProducts(int subcategoryId);

  /// Obtém detalhes completos de um produto
  Future<ProductConfigDto> getProductDetails(int productId);

  /// Atualiza um produto
  Future<ProductConfigDto> updateProduct(
      int productId, Map<String, dynamic> data);

  /// Atualiza apenas o status de um produto (PATCH)
  Future<void> updateProductStatus(int productId, bool status);

  /// Obtém indicadores de etapa agrupados
  Future<List<IndicatorGroupDto>> getIndicators();
}
