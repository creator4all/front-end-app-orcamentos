import '../../../../../../../app/shared/utils/date_utils.dart';
import '../../domain/entities/cidade_indice_etapa_entity.dart';
import 'indice_etapa_dto.dart';

class CidadeIndiceEtapaDto {
  final int indiceEtapaId;
  final String nomeEtapa;
  final String tituloEtapa;
  final int grupoId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double etapaValor;
  final IndiceEtapaDto indiceEtapa;

  const CidadeIndiceEtapaDto({
    required this.indiceEtapaId,
    required this.nomeEtapa,
    required this.tituloEtapa,
    required this.grupoId,
    required this.createdAt,
    required this.updatedAt,
    required this.etapaValor,
    required this.indiceEtapa,
  });

  factory CidadeIndiceEtapaDto.fromJson(Map<String, dynamic> json) {
    final indiceEtapaJson = json;
    final pivotJson = json['pivot'] as Map<String, dynamic>? ?? {};

    return CidadeIndiceEtapaDto(
      indiceEtapaId: (indiceEtapaJson['idindice_etapa'] as num?)?.toInt() ?? 0,
      nomeEtapa: indiceEtapaJson['nome_etapa'] as String? ?? '',
      tituloEtapa: indiceEtapaJson['titulo_etapa'] as String? ??
          indiceEtapaJson['nome_etapa'] as String? ??
          '',
      grupoId: (indiceEtapaJson['grupos_grupo_id'] as num?)?.toInt() ?? 0,
      createdAt: parseDate(indiceEtapaJson['created_at']) ?? DateTime.now(),
      updatedAt: parseDate(indiceEtapaJson['updated_at']) ?? DateTime.now(),
      etapaValor:
          double.tryParse(pivotJson['etapa_valor']?.toString() ?? '0') ?? 0.0,
      indiceEtapa: IndiceEtapaDto.fromJson(indiceEtapaJson),
    );
  }

  CidadeIndiceEtapaEntity toEntity() {
    return CidadeIndiceEtapaEntity(
      indiceEtapaId: indiceEtapaId,
      nomeEtapa: nomeEtapa,
      tituloEtapa: tituloEtapa,
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
