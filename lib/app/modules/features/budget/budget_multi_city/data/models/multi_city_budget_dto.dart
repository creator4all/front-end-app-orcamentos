/// DTO para override de valor do censo
class CensusOverrideDto {
  final int indiceEtapaId;
  final double valor;

  const CensusOverrideDto({
    required this.indiceEtapaId,
    required this.valor,
  });

  Map<String, dynamic> toMap() {
    return {
      'indice_etapa_id': indiceEtapaId,
      'valor': valor,
    };
  }
}

/// DTO para censo de uma cidade específica
class CidadeCensoDto {
  final int cidadeId;
  final List<CensusOverrideDto> overrides;

  const CidadeCensoDto({
    required this.cidadeId,
    this.overrides = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'cidade_id': cidadeId,
      'overrides': overrides.map((o) => o.toMap()).toList(),
    };
  }
}

/// DTO para criação de orçamento multi-cidades
class MultiCityBudgetDto {
  final String nome;
  final int diasValidade;
  final List<CidadeCensoDto> cidades;
  final int? partnerDestinoId;
  final int usuarioId;

  const MultiCityBudgetDto({
    required this.nome,
    required this.diasValidade,
    required this.cidades,
    required this.usuarioId,
    this.partnerDestinoId,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'orc_nome': nome,
      'orc_dias_validade': diasValidade,
      'orc_usuario_id': usuarioId,
      'cidades': cidades.map((c) => c.toMap()).toList(),
    };

    if (partnerDestinoId != null) {
      map['orc_partner_destino_id'] = partnerDestinoId;
    }

    return map;
  }
}
