import '../models/prospect_dto.dart';

abstract class ProspectDatasource {
  Future<PaginatedProspectsDto> getProspects({
    int page = 1,
    bool? isContatado,
  });

  Future<ProspectDto> updateProspect(int id, bool isContatado);
}
