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
    final grupoJson = json['grupo'] as Map<String, dynamic>? ?? {};

    final grupoId = (indiceEtapaJson['grupos_grupo_id'] as num?)?.toInt() ??
        (indiceEtapaJson['grupo_id'] as num?)?.toInt() ??
        (grupoJson['id'] as num?)?.toInt() ??
        (grupoJson['grupo_id'] as num?)?.toInt() ??
        0;

    final valor = indiceEtapaJson['valor'] ??
        indiceEtapaJson['etapa_valor'] ??
        pivotJson['etapa_valor'];

    return CidadeIndiceEtapaDto(
      indiceEtapaId: (indiceEtapaJson['idindice_etapa'] as num?)?.toInt() ??
          (indiceEtapaJson['id'] as num?)?.toInt() ??
          (indiceEtapaJson['indice_etapa_id'] as num?)?.toInt() ??
          0,
      nomeEtapa:
          indiceEtapaJson['nome_etapa'] as String? ??
              indiceEtapaJson['nome'] as String? ??
              '',
      tituloEtapa: indiceEtapaJson['titulo'] as String? ??
          indiceEtapaJson['titulo_etapa'] as String? ??
          indiceEtapaJson['nome'] as String? ??
          indiceEtapaJson['nome_etapa'] as String? ??
          '',
      grupoId: grupoId,
      createdAt: parseDate(indiceEtapaJson['created_at']) ?? DateTime.now(),
      updatedAt: parseDate(indiceEtapaJson['updated_at']) ?? DateTime.now(),
      etapaValor: double.tryParse(valor?.toString() ?? '0') ?? 0.0,
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
      'titulo_etapa': tituloEtapa,
      'grupos_grupo_id': grupoId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'valor': etapaValor,
      'grupo': {
        'grupo_id': grupoId,
        'nome_grupo': indiceEtapa.grupoNome,
      },
      'pivot': {
        'etapa_valor': etapaValor,
      },
    };
  }
}
