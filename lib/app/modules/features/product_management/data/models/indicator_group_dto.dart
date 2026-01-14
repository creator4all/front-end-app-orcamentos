import '../../domain/entities/indicator_group_entity.dart';

/// DTO para parsing JSON de indicador individual
class IndicatorDto {
  final int id;
  final String nome;
  final String titulo;

  IndicatorDto({
    required this.id,
    required this.nome,
    required this.titulo,
  });

  factory IndicatorDto.fromJson(Map<String, dynamic> json) {
    return IndicatorDto(
      id: json['ind_id'] as int? ?? 0,
      nome: json['ind_nome'] as String? ?? '',
      titulo: json['ind_titulo'] as String? ?? '',
    );
  }

  IndicatorEntity toEntity() {
    return IndicatorEntity(
      id: id,
      nome: nome,
      titulo: titulo,
    );
  }
}

/// DTO para parsing JSON de grupo de indicadores
class IndicatorGroupDto {
  final int id;
  final String nome;
  final List<IndicatorDto> indicadores;

  IndicatorGroupDto({
    required this.id,
    required this.nome,
    required this.indicadores,
  });

  factory IndicatorGroupDto.fromJson(Map<String, dynamic> json) {
    final grupo = json['grupo'] as Map<String, dynamic>? ?? {};
    final indicadoresList = json['indicadores'] as List<dynamic>? ?? [];

    return IndicatorGroupDto(
      id: grupo['gru_gruposId'] as int? ?? 0,
      nome: grupo['gru_grupo_nome'] as String? ?? '',
      indicadores: indicadoresList
          .map((e) => IndicatorDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  IndicatorGroupEntity toEntity() {
    return IndicatorGroupEntity(
      id: id,
      nome: nome,
      indicadores: indicadores.map((e) => e.toEntity()).toList(),
    );
  }
}
