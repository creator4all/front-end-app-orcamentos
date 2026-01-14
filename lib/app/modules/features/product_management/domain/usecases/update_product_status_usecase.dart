import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../repositories/product_config_repository.dart';

/// Caso de uso para atualizar apenas o status de um produto
class UpdateProductStatusUsecase {
  final ProductConfigRepository repository;

  UpdateProductStatusUsecase({required this.repository});

  /// Executa a atualização do status do produto
  Future<Either<Failure, Unit>> call(int productId, bool status) async {
    return await repository.updateProductStatus(productId, status);
  }
}
