import 'package:equatable/equatable.dart';

/// Entidade que representa os dados do Censo Escolar de uma cidade
class CensusDataEntity extends Equatable {
  /// ID da cidade
  final int cityId;

  /// Nome da cidade
  final String cityName;

  /// Total de turmas
  final int totalClasses;

  /// Total de alunos
  final int totalStudents;

  /// Distribuição por série/ano (ex: {"1º ano": 150, "2º ano": 200})
  final Map<String, int> gradeDistribution;

  const CensusDataEntity({
    required this.cityId,
    required this.cityName,
    required this.totalClasses,
    required this.totalStudents,
    required this.gradeDistribution,
  });

  // ========== Regras de Negócio ==========

  /// Verifica se há dados disponíveis
  bool get hasData => totalClasses > 0 || totalStudents > 0;

  /// Retorna um resumo formatado
  String get summary => '$totalClasses turmas, $totalStudents alunos';

  /// Calcula média de alunos por turma
  double get averageStudentsPerClass =>
      totalClasses > 0 ? totalStudents / totalClasses : 0.0;

  @override
  List<Object?> get props => [
        cityId,
        cityName,
        totalClasses,
        totalStudents,
        gradeDistribution,
      ];

  /// Cria uma cópia com campos alterados
  CensusDataEntity copyWith({
    int? cityId,
    String? cityName,
    int? totalClasses,
    int? totalStudents,
    Map<String, int>? gradeDistribution,
  }) {
    return CensusDataEntity(
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      totalClasses: totalClasses ?? this.totalClasses,
      totalStudents: totalStudents ?? this.totalStudents,
      gradeDistribution: gradeDistribution ?? this.gradeDistribution,
    );
  }
}
