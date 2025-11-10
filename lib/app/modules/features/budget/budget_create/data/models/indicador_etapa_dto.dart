import '../../domain/entities/indicador_etapa_entity.dart';
import 'indice_etapa_dto.dart';

/// DTO para IndicadorEtapa
class IndicadorEtapaDto {
  final int id;
  final bool valor;
  final int produtoId;
  final int indiceEtapaId;
  final IndiceEtapaDto indiceEtapa;

  const IndicadorEtapaDto({
    required this.id,
    required this.valor,
    required this.produtoId,
    required this.indiceEtapaId,
    required this.indiceEtapa,
  });

  factory IndicadorEtapaDto.fromJson(Map<String, dynamic> json) {
    final indiceEtapaJson = json['indicador_etapa'] as Map<String, dynamic>? ?? {};
    
    return IndicadorEtapaDto(
      id: (json['prd_produtos_indicadoresId'] as num?)?.toInt() ?? 0,
      valor: json['prd_valor'] as bool? ?? false,
      produtoId: (json['produtos_pro_produtosId'] as num?)?.toInt() ?? 0,
      indiceEtapaId: (json['indicadores_etapa_ine_indicadoresId'] as num?)?.toInt() ?? 0,
      indiceEtapa: IndiceEtapaDto.fromJson(indiceEtapaJson),
    );
  }

  IndicadorEtapaEntity toEntity() {
    return IndicadorEtapaEntity(
      id: id,
      valor: valor,
      produtoId: produtoId,
      indiceEtapaId: indiceEtapaId,
      indiceEtapa: indiceEtapa.toEntity(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prd_produtos_indicadoresId': id,
      'prd_valor': valor,
      'produtos_pro_produtosId': produtoId,
      'indicadores_etapa_ine_indicadoresId': indiceEtapaId,
      'indicador_etapa': indiceEtapa.toJson(),
    };
  }
}
