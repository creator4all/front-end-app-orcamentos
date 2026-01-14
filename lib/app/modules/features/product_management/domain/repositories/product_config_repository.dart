import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/category_entity.dart';
import '../entities/indicator_group_entity.dart';
import '../entities/product_config_entity.dart';
import '../entities/subcategory_entity.dart';

/// Contrato abstrato do repositório de configuração de produtos
abstract class ProductConfigRepository {
  /// Obtém todas as categorias
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  /// Obtém subcategorias de uma categoria específica
  Future<Either<Failure, List<SubcategoryEntity>>> getSubcategories(
      int categoryId);

  /// Obtém produtos de uma subcategoria específica
  Future<Either<Failure, List<ProductConfigEntity>>> getProducts(
      int subcategoryId);

  /// Obtém detalhes completos de um produto
  Future<Either<Failure, ProductConfigEntity>> getProductDetails(int productId);

  /// Atualiza um produto
  Future<Either<Failure, ProductConfigEntity>> updateProduct(
      ProductConfigEntity product);

  /// Atualiza apenas o status de um produto
  Future<Either<Failure, Unit>> updateProductStatus(int productId, bool status);

  /// Obtém indicadores de etapa agrupados
  Future<Either<Failure, List<IndicatorGroupEntity>>> getIndicators();
}
