import '../../domain/entities/indice_etapa_entity.dart';

/// DTO para IndiceEtapa
class IndiceEtapaDto {
  final int id;
  final String nome;
  final int grupoId;
  final String? grupoNome;
  final DateTime createdAt;
  final DateTime updatedAt;

  const IndiceEtapaDto({
    required this.id,
    required this.nome,
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
      grupoId: (json['grupos_grupo_id'] as num?)?.toInt() ?? 0,
      grupoNome: grupoJson?['gru_grupo_nome'] as String?,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
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

  IndiceEtapaEntity toEntity() {
    return IndiceEtapaEntity(
      id: id,
      nome: nome,
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
