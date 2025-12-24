import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/prospect_entity.dart';
import '../repositories/prospect_repository.dart';

/// Caso de uso para marcar um prospect como contactado
class MarkContactedUsecase {
  final ProspectRepository _repository;

  MarkContactedUsecase(this._repository);

  /// Executa o caso de uso
  /// [prospectId] - ID do prospect a ser marcado como contactado
  Future<Either<Failure, ProspectEntity>> call(int prospectId) {
    return _repository.markAsContacted(prospectId);
  }
}
