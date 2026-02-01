import '../../../../../../../app/shared/utils/date_utils.dart';
import '../../domain/entities/indice_etapa_entity.dart';

class IndiceEtapaDto {
  final int id;
  final String nome;
  final String titulo;
  final int grupoId;
  final String? grupoNome;
  final DateTime createdAt;
  final DateTime updatedAt;

  const IndiceEtapaDto({
    required this.id,
    required this.nome,
    required this.titulo,
    required this.grupoId,
    this.grupoNome,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IndiceEtapaDto.fromJson(Map<String, dynamic> json) {
    final grupoJson = json['grupo'] as Map<String, dynamic>?;

    return IndiceEtapaDto(
      id: (json['idindice_etapa'] as num?)?.toInt() ?? 0,
      nome: json['nome_etapa'] as String? ?? '',
      titulo: json['titulo_etapa'] as String? ??
          json['nome_etapa'] as String? ??
          '',
      grupoId: (json['grupos_grupo_id'] as num?)?.toInt() ?? 0,
      grupoNome: grupoJson?['nome_grupo'] as String?,
      createdAt: parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: parseDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  IndiceEtapaEntity toEntity() {
    return IndiceEtapaEntity(
      id: id,
      nome: nome,
      titulo: titulo,
      grupoId: grupoId,
      grupoNome: grupoNome ?? '',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idindice_etapa': id,
      'nome_etapa': nome,
      'grupos_grupo_id': grupoId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
