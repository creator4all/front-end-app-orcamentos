import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';

part 'location_entity.g.dart';

/// Entidade que representa uma Localização (Estado + Cidade)
@CopyWith()
class LocationEntity extends Equatable {
  final String stateCode;
  final String stateName;
  final String cityCode;
  final String cityName;

  const LocationEntity({
    required this.stateCode,
    required this.stateName,
    required this.cityCode,
    required this.cityName,
  });

  /// Retorna a localização completa formatada
  String get fullLocation => '$cityName - $stateCode';

  /// Verifica se a localização está completa
  bool get isValid =>
      stateCode.isNotEmpty &&
      stateName.isNotEmpty &&
      cityCode.isNotEmpty &&
      cityName.isNotEmpty;

  @override
  List<Object?> get props => [stateCode, stateName, cityCode, cityName];

  @override
  bool get stringify => true;
}
