import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/subcategory_entity.dart';
import '../repositories/product_config_repository.dart';

/// Caso de uso para obter subcategorias de uma categoria
class GetSubcategoriesUsecase {
  final ProductConfigRepository repository;

  GetSubcategoriesUsecase(this.repository);

  Future<Either<Failure, List<SubcategoryEntity>>> call(int categoryId) {
    return repository.getSubcategories(categoryId);
  }
}
