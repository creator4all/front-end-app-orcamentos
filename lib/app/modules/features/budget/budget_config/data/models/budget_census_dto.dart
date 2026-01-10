import '../../domain/entities/censo_escolar_entity.dart';
import '../../domain/entities/censo_group_entity.dart';
import '../../domain/entities/censo_title_entity.dart';

/// DTO para cidade com dados de censo
class CidadeCensoDto {
  final int id;
  final String nome;
  final List<IndiceCensoDto> indices;

  const CidadeCensoDto({
    required this.id,
    required this.nome,
    required this.indices,
  });

  factory CidadeCensoDto.fromJson(Map<String, dynamic> json) {
    final indicesJson = json['indices'] as List<dynamic>? ?? [];
    return CidadeCensoDto(
      id: json['id'] as int? ?? 0,
      nome: json['nome'] as String? ?? '',
      indices: indicesJson
          .map((e) => IndiceCensoDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converte para CensoEscolarEntity para uso na UI
  CensoEscolarEntity toEntity() {
    // Agrupar indices por grupo
    final gruposMap = <int, List<CensoTitleEntity>>{};
    final grupoNomes = <int, String>{};

    for (final indice in indices) {
      final grupoId = indice.grupo?.id ?? 0;
      grupoNomes[grupoId] = indice.grupo?.nome ?? '';

      gruposMap.putIfAbsent(grupoId, () => []);
      gruposMap[grupoId]!.add(CensoTitleEntity(
        id: indice.id,
        nomeEtapa: indice.nomeEtapa,
        tituloExibicao: indice.titulo,
        valor: indice.valor,
        isProfessores: indice.nomeEtapa.endsWith('P'),
        grupoId: grupoId,
      ));
    }

    // Converter grupos map para entidades
    final grupos = gruposMap.entries.map((entry) {
      return CensoGroupEntity(
        id: entry.key,
        nome: grupoNomes[entry.key] ?? '',
        titulos: entry.value,
      );
    }).toList();

    // Criar mapa de valores por etapa
    final valoresPorEtapa = <String, double>{};
    for (final indice in indices) {
      valoresPorEtapa[indice.nomeEtapa] = indice.valor;
    }

    return CensoEscolarEntity(
      cidadeId: id,
      cidadeNome: nome,
      grupos: grupos,
      valoresPorEtapa: valoresPorEtapa,
    );
  }
}

/// DTO para índice de censo
class IndiceCensoDto {
  final int id;
  final String nomeEtapa;
  final String titulo;
  final double valor;
  final GrupoCensoDto? grupo;

  const IndiceCensoDto({
    required this.id,
    required this.nomeEtapa,
    required this.titulo,
    required this.valor,
    this.grupo,
  });

  factory IndiceCensoDto.fromJson(Map<String, dynamic> json) {
    return IndiceCensoDto(
      id: json['id'] as int? ?? 0,
      nomeEtapa: json['nome_etapa'] as String? ?? '',
      titulo: json['titulo'] as String? ?? '',
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      grupo: json['grupo'] != null
          ? GrupoCensoDto.fromJson(json['grupo'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// DTO para grupo de censo
class GrupoCensoDto {
  final int id;
  final String nome;

  const GrupoCensoDto({
    required this.id,
    required this.nome,
  });

  factory GrupoCensoDto.fromJson(Map<String, dynamic> json) {
    return GrupoCensoDto(
      id: json['id'] as int? ?? 0,
      nome: json['nome'] as String? ?? '',
    );
  }
}

/// DTO para resposta completa do endpoint GET /api/orcamentos/{id}/censo
class BudgetCensusDto {
  final int orcamentoId;
  final bool multiCidade;
  final List<CidadeCensoDto> cidades;
  final Map<String, double> censoAgregado;

  const BudgetCensusDto({
    required this.orcamentoId,
    required this.multiCidade,
    required this.cidades,
    required this.censoAgregado,
  });

  factory BudgetCensusDto.fromJson(Map<String, dynamic> json) {
    // Extrair dados do wrapper "dados" se existir
    final dados = json['dados'] as Map<String, dynamic>? ?? json;

    final cidadesJson = dados['cidades'] as List<dynamic>? ?? [];
    final censoAgregadoJson =
        dados['censo_agregado'] as Map<String, dynamic>? ?? {};

    return BudgetCensusDto(
      orcamentoId: dados['orcamento_id'] as int? ?? 0,
      multiCidade: dados['multi_cidade'] as bool? ?? false,
      cidades: cidadesJson
          .map((e) => CidadeCensoDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      censoAgregado: censoAgregadoJson.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );
  }
}
