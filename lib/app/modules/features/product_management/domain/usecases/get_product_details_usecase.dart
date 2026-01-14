import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/product_config_entity.dart';
import '../repositories/product_config_repository.dart';

/// Caso de uso para obter detalhes completos de um produto
class GetProductDetailsUsecase {
  final ProductConfigRepository repository;

  GetProductDetailsUsecase(this.repository);

  Future<Either<Failure, ProductConfigEntity>> call(int productId) {
    return repository.getProductDetails(productId);
  }
}
