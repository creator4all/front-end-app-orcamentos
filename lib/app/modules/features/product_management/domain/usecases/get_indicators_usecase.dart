import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/indicator_group_entity.dart';
import '../repositories/product_config_repository.dart';

/// Caso de uso para obter indicadores de etapa agrupados
class GetIndicatorsUsecase {
  final ProductConfigRepository repository;

  GetIndicatorsUsecase(this.repository);

  Future<Either<Failure, List<IndicatorGroupEntity>>> call() {
    return repository.getIndicators();
  }
}
