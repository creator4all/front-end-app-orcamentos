import '../../domain/entities/cidade_indice_etapa_entity.dart';
import 'indice_etapa_dto.dart';

/// DTO para CidadeIndiceEtapa
class CidadeIndiceEtapaDto {
  final int indiceEtapaId;
  final String nomeEtapa;
  final int grupoId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double etapaValor;
  final IndiceEtapaDto indiceEtapa;

  const CidadeIndiceEtapaDto({
    required this.indiceEtapaId,
    required this.nomeEtapa,
    required this.grupoId,
    required this.createdAt,
    required this.updatedAt,
    required this.etapaValor,
    required this.indiceEtapa,
  });

  factory CidadeIndiceEtapaDto.fromJson(Map<String, dynamic> json) {
    final indiceEtapaJson = json as Map<String, dynamic>;
    final pivotJson = json['pivot'] as Map<String, dynamic>? ?? {};

    return CidadeIndiceEtapaDto(
      indiceEtapaId: (indiceEtapaJson['idindice_etapa'] as num?)?.toInt() ?? 0,
      nomeEtapa: indiceEtapaJson['nome_etapa'] as String? ?? '',
      grupoId: (indiceEtapaJson['grupos_grupo_id'] as num?)?.toInt() ?? 0,
      createdAt: _parseDate(indiceEtapaJson['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(indiceEtapaJson['updated_at']) ?? DateTime.now(),
      etapaValor: double.tryParse(pivotJson['etapa_valor']?.toString() ?? '0') ?? 0.0,
      indiceEtapa: IndiceEtapaDto.fromJson(indiceEtapaJson),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  CidadeIndiceEtapaEntity toEntity() {
    return CidadeIndiceEtapaEntity(
      indiceEtapaId: indiceEtapaId,
      nomeEtapa: nomeEtapa,
      grupoId: grupoId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      etapaValor: etapaValor,
      indiceEtapa: indiceEtapa.toEntity(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idindice_etapa': indiceEtapaId,
      'nome_etapa': nomeEtapa,
      'grupos_grupo_id': grupoId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'pivot': {
        'etapa_valor': etapaValor.toString(),
      },
    };
  }
}
