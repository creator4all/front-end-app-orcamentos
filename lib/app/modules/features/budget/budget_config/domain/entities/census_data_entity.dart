import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';

part 'census_data_entity.g.dart';

@CopyWith()
class CensusDataEntity extends Equatable {
  final int cityId;

  final String cityName;

  final int totalClasses;

  final int totalStudents;

  final Map<String, int> gradeDistribution;

  const CensusDataEntity({
    required this.cityId,
    required this.cityName,
    required this.totalClasses,
    required this.totalStudents,
    required this.gradeDistribution,
  });


  bool get hasData => totalClasses > 0 || totalStudents > 0;

  String get summary => '$totalClasses turmas, $totalStudents alunos';

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
}
