import '../../domain/entities/census_data_entity.dart';

/// DTO para dados do Censo Escolar
/// Responsável pela conversão JSON <-> Entity
class CensusDataDto {
  final int cityId;
  final String cityName;
  final int totalClasses;
  final int totalStudents;
  final Map<String, int> gradeDistribution;

  CensusDataDto({
    required this.cityId,
    required this.cityName,
    required this.totalClasses,
    required this.totalStudents,
    required this.gradeDistribution,
  });

  factory CensusDataDto.fromJson(Map<String, dynamic> json) {
    final Map<String, int> grades = {};
    final seriesJson = json['series'] as Map?;
    if (seriesJson != null) {
      seriesJson.forEach((key, value) {
        grades[key.toString()] = (value ?? 0) as int;
      });
    }

    return CensusDataDto(
      cityId: json['cidade_id'] as int? ?? 0,
      cityName: (json['cidade_nome'] ?? '') as String,
      totalClasses: json['turmas'] as int? ?? 0,
      totalStudents: json['alunos'] as int? ?? 0,
      gradeDistribution: grades,
    );
  }

  /// Converte DTO para JSON
  Map<String, dynamic> toJson() {
    return {
      'cidade_id': cityId,
      'cidade_nome': cityName,
      'turmas': totalClasses,
      'alunos': totalStudents,
      'series': gradeDistribution,
    };
  }

  /// Converte DTO para Entity
  CensusDataEntity toEntity() {
    return CensusDataEntity(
      cityId: cityId,
      cityName: cityName,
      totalClasses: totalClasses,
      totalStudents: totalStudents,
      gradeDistribution: gradeDistribution,
    );
  }

  /// Cria DTO a partir de Entity
  factory CensusDataDto.fromEntity(CensusDataEntity entity) {
    return CensusDataDto(
      cityId: entity.cityId,
      cityName: entity.cityName,
      totalClasses: entity.totalClasses,
      totalStudents: entity.totalStudents,
      gradeDistribution: entity.gradeDistribution,
    );
  }
}
