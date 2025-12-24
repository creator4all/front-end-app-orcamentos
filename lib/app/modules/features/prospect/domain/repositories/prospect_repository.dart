import 'package:dartz/dartz.dart';

import '../../../../../shared/core/errors/failures.dart';
import '../entities/prospect_entity.dart';

/// Interface abstrata do repositório de prospecção
/// Define os contratos para operações de prospecção de parceiros
abstract class ProspectRepository {
  /// Lista prospects com paginação e filtro opcional por status de contato
  /// [page] - Número da página (default: 1)
  /// [isContatado] - Filtro opcional: true = contactados, false = não contactados, null = todos
  Future<Either<Failure, PaginatedProspects>> getProspects({
    int page = 1,
    bool? isContatado,
  });

  /// Marca um prospect como contactado
  /// [id] - ID do prospect
  /// Retorna o prospect atualizado ou um Failure
  Future<Either<Failure, ProspectEntity>> markAsContacted(int id);
}
