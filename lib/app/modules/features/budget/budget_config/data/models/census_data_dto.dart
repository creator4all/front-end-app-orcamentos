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

  /// Cria DTO a partir do JSON da API
  factory CensusDataDto.fromJson(Map<String, dynamic> json) {
    // Parse distribuição por série
    final Map<String, int> grades = {};
    if (json['series'] != null && json['series'] is Map) {
      (json['series'] as Map).forEach((key, value) {
        grades[key.toString()] = (value ?? 0) as int;
      });
    } else if (json['distribuicao'] != null && json['distribuicao'] is Map) {
      (json['distribuicao'] as Map).forEach((key, value) {
        grades[key.toString()] = (value ?? 0) as int;
      });
    }

    return CensusDataDto(
      cityId: json['cidade_id'] ?? json['city_id'] ?? 0,
      cityName: json['cidade_nome'] ?? json['city_name'] ?? '',
      totalClasses: json['turmas'] ?? json['total_classes'] ?? 0,
      totalStudents: json['alunos'] ?? json['total_students'] ?? 0,
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
