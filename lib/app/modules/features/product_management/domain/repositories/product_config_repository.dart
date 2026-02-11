import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/category_entity.dart';
import '../entities/indicator_group_entity.dart';
import '../entities/product_config_entity.dart';
import '../entities/subcategory_entity.dart';

abstract class ProductConfigRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  Future<Either<Failure, List<SubcategoryEntity>>> getSubcategories(
      int categoryId);

  Future<Either<Failure, List<ProductConfigEntity>>> getProducts(
      int subcategoryId);

  Future<Either<Failure, ProductConfigEntity>> getProductDetails(int productId);

  Future<Either<Failure, ProductConfigEntity>> updateProduct(
      ProductConfigEntity product);

  Future<Either<Failure, Unit>> updateProductStatus(int productId, bool status);

  Future<Either<Failure, List<IndicatorGroupEntity>>> getIndicators();
}
