import 'package:equatable/equatable.dart';

/// Entidade que representa uma Localização (Estado + Cidade)
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

  /// Retorna apenas o nome da cidade
  String get cityDisplay => cityName;

  /// Retorna apenas o nome do estado
  String get stateDisplay => stateName;

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

  LocationEntity copyWith({
    String? stateCode,
    String? stateName,
    String? cityCode,
    String? cityName,
  }) {
    return LocationEntity(
      stateCode: stateCode ?? this.stateCode,
      stateName: stateName ?? this.stateName,
      cityCode: cityCode ?? this.cityCode,
      cityName: cityName ?? this.cityName,
    );
  }
}
