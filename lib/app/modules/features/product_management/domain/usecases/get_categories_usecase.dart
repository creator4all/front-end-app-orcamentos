import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/product_config_repository.dart';

/// Caso de uso para obter todas as categorias
class GetCategoriesUsecase {
  final ProductConfigRepository repository;

  GetCategoriesUsecase(this.repository);

  Future<Either<Failure, List<CategoryEntity>>> call() {
    return repository.getCategories();
  }
}
