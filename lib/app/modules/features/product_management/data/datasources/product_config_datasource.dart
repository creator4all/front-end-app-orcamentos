import '../models/category_dto.dart';
import '../models/indicator_group_dto.dart';
import '../models/product_config_dto.dart';
import '../models/subcategory_dto.dart';

abstract class ProductConfigDatasource {
  Future<List<CategoryDto>> getCategories();

  Future<List<SubcategoryDto>> getSubcategories(int categoryId);

  Future<List<ProductConfigDto>> getProducts(int subcategoryId);

  Future<ProductConfigDto> getProductDetails(int productId);

  Future<ProductConfigDto> updateProduct(
      int productId, Map<String, dynamic> data);

  Future<void> updateProductStatus(int productId, bool status);

  Future<List<IndicatorGroupDto>> getIndicators();
}
