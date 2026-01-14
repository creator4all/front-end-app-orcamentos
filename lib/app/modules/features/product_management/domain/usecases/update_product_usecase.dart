import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/product_config_entity.dart';
import '../repositories/product_config_repository.dart';

/// Caso de uso para atualizar um produto
class UpdateProductUsecase {
  final ProductConfigRepository repository;

  UpdateProductUsecase(this.repository);

  Future<Either<Failure, ProductConfigEntity>> call(
      ProductConfigEntity product) {
    return repository.updateProduct(product);
  }
}
