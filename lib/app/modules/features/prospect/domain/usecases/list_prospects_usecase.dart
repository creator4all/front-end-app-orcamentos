import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/prospect_entity.dart';
import '../repositories/prospect_repository.dart';

/// Caso de uso para listar prospects com paginação e filtro
class ListProspectsUsecase {
  final ProspectRepository _repository;

  ListProspectsUsecase(this._repository);

  /// Executa o caso de uso
  /// [page] - Número da página para paginação
  /// [isContatado] - Filtro opcional por status de contato
  Future<Either<Failure, PaginatedProspects>> call({
    int page = 1,
    bool? isContatado,
  }) {
    return _repository.getProspects(
      page: page,
      isContatado: isContatado,
    );
  }
}
