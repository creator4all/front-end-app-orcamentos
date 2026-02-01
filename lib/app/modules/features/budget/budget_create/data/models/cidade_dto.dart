import '../../../../../../../app/shared/utils/date_utils.dart';
import '../../domain/entities/cidade_entity.dart';
import 'cidade_indice_etapa_dto.dart';

class CidadeDto {
  final int id;
  final String nome;
  final int estadoId;
  final bool status;
  final bool excluido;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CidadeIndiceEtapaDto> cidadesHasIndiceEtapa;

  const CidadeDto({
    required this.id,
    required this.nome,
    required this.estadoId,
    required this.status,
    required this.excluido,
    required this.createdAt,
    required this.updatedAt,
    required this.cidadesHasIndiceEtapa,
  });

  factory CidadeDto.fromJson(Map<String, dynamic> json) {
    final etapasArray = json['cidades_has_indice_etapa'] as List? ?? [];
    final etapas = etapasArray
        .map((item) =>
            CidadeIndiceEtapaDto.fromJson(item as Map<String, dynamic>))
        .toList();

    return CidadeDto(
      id: (json['idCidades'] as num?)?.toInt() ?? 0,
      nome: json['nome_cidade'] as String? ?? '',
      estadoId: (json['estados_idestados'] as num?)?.toInt() ?? 0,
      status: json['status'] as bool? ?? false,
      excluido: json['excluido'] as bool? ?? false,
      createdAt: parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: parseDate(json['updated_at']) ?? DateTime.now(),
      cidadesHasIndiceEtapa: etapas,
    );
  }

  CidadeEntity toEntity() {
    return CidadeEntity(
      id: id,
      nome: nome,
      estadoId: estadoId,
      status: status,
      excluido: excluido,
      createdAt: createdAt,
      updatedAt: updatedAt,
      cidadesHasIndiceEtapa:
          cidadesHasIndiceEtapa.map((dto) => dto.toEntity()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCidades': id,
      'nome_cidade': nome,
      'estados_idestados': estadoId,
      'status': status,
      'excluido': excluido,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'cidades_has_indice_etapa':
          cidadesHasIndiceEtapa.map((dto) => dto.toJson()).toList(),
    };
  }
}
