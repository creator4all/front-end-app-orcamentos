import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/product_config_entity.dart';
import '../repositories/product_config_repository.dart';

/// Caso de uso para obter produtos de uma subcategoria
class GetProductsUsecase {
  final ProductConfigRepository repository;

  GetProductsUsecase(this.repository);

  Future<Either<Failure, List<ProductConfigEntity>>> call(int subcategoryId) {
    return repository.getProducts(subcategoryId);
  }
}
