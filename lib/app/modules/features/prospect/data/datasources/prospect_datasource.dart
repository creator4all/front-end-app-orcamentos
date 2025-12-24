import '../models/prospect_dto.dart';

/// Interface abstrata do datasource de prospecção
/// Define os contratos para acesso aos dados de prospects
abstract class ProspectDatasource {
  /// Lista prospects com paginação e filtro opcional
  /// [page] - Número da página
  /// [isContatado] - Filtro por status de contato (null = todos)
  Future<PaginatedProspectsDto> getProspects({
    int page = 1,
    bool? isContatado,
  });

  /// Atualiza o status de contato de um prospect
  /// [id] - ID do prospect
  /// [isContatado] - Novo status de contato
  Future<ProspectDto> updateProspect(int id, bool isContatado);
}
