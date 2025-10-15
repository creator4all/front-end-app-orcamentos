import '../models/census_data_dto.dart';

/// Interface abstrata para operações remotas de dados do Censo Escolar
abstract class CensusRemoteDataSource {
  /// Busca dados agregados do censo para uma cidade
  Future<CensusDataDto> getCensusData(int cityId);

  /// Busca dados do censo para múltiplas cidades
  Future<List<CensusDataDto>> getMultipleCitiesCensusData(List<int> cityIds);
}
