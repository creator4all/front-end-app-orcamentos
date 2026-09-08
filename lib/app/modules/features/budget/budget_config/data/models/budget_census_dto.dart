import 'package:multimidiaapp/app/shared/domain/value_objects/fractional_order.dart';

import '../../../../../../shared/utils/api_number_parser.dart';
import '../../domain/entities/budget_census_entity.dart';
import '../../domain/entities/censo_escolar_entity.dart';
import '../../domain/entities/censo_group_entity.dart';
import '../../domain/entities/censo_title_entity.dart';

class CidadeCensoDto {
  final int id;
  final String nome;
  final int? censoAno;
  final int? anoPopulacao;
  final List<IndiceCensoDto> indices;

  const CidadeCensoDto({
    required this.id,
    required this.nome,
    this.censoAno,
    this.anoPopulacao,
    required this.indices,
  });

  factory CidadeCensoDto.fromJson(Map<String, dynamic> json) {
    final indicesJson = json['indices'] as List<dynamic>? ?? [];
    return CidadeCensoDto(
      id: ApiNumberParser.toInt(json['id']),
      nome: json['nome'] as String? ?? '',
      censoAno: ApiNumberParser.toIntOrNull(json['censo_ano']),
      anoPopulacao: ApiNumberParser.toIntOrNull(json['ano_populacao']),
      indices: indicesJson
          .map((e) => IndiceCensoDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory CidadeCensoDto.fromEntity(CensoEscolarEntity entity) {
    return CidadeCensoDto(
      id: entity.cidadeId,
      nome: entity.cidadeNome,
      censoAno: entity.censoAno,
      anoPopulacao: entity.anoPopulacao,
      indices: entity.grupos
          .expand((g) => g.titulos.map((t) => IndiceCensoDto.fromEntity(t, g)))
          .toList(),
    );
  }

  CensoEscolarEntity toEntity() {
    final gruposMap = <int, List<CensoTitleEntity>>{};
    final grupoNomes = <int, String>{};
    final grupoOrdens = <int, FractionalOrder>{};

    for (final indice in indices) {
      final grupoId = indice.grupo?.id ?? 0;
      grupoNomes[grupoId] = indice.grupo?.nome ?? '';
      grupoOrdens[grupoId] = indice.grupo?.ordem ?? FractionalOrder.zero;

      gruposMap.putIfAbsent(grupoId, () => []);
      gruposMap[grupoId]!.add(CensoTitleEntity(
        id: indice.id,
        nomeEtapa: indice.nomeEtapa,
        tituloExibicao: indice.titulo,
        valor: indice.valor,
        isProfessores: indice.nomeEtapa.endsWith('P'),
        grupoId: grupoId,
        percentualPopulacao: indice.percentualPopulacao,
        ordem: indice.ordem,
      ));
    }

    final grupos = gruposMap.entries.map((entry) {
      final titulos = entry.value..sort((a, b) => a.ordem.compareTo(b.ordem));
      return CensoGroupEntity(
        id: entry.key,
        nome: grupoNomes[entry.key] ?? '',
        titulos: titulos,
        ordem: grupoOrdens[entry.key] ?? FractionalOrder.zero,
      );
    }).toList()
      ..sort((a, b) => a.ordem.compareTo(b.ordem));

    final valoresPorEtapa = <String, double>{};
    for (final indice in indices) {
      valoresPorEtapa[indice.nomeEtapa] = indice.valor;
    }

    return CensoEscolarEntity(
      cidadeId: id,
      cidadeNome: nome,
      censoAno: censoAno,
      anoPopulacao: anoPopulacao,
      grupos: grupos,
      valoresPorEtapa: valoresPorEtapa,
    );
  }
}

class IndiceCensoDto {
  final int id;
  final String nomeEtapa;
  final String titulo;
  final double valor;
  final double? percentualPopulacao;
  final FractionalOrder ordem;
  final GrupoCensoDto? grupo;

  const IndiceCensoDto({
    required this.id,
    required this.nomeEtapa,
    required this.titulo,
    required this.valor,
    this.percentualPopulacao,
    this.ordem = FractionalOrder.zero,
    this.grupo,
  });

  factory IndiceCensoDto.fromJson(Map<String, dynamic> json) {
    return IndiceCensoDto(
      id: ApiNumberParser.toInt(json['id']),
      nomeEtapa: json['nome_etapa'] as String? ?? '',
      titulo: json['titulo'] as String? ?? '',
      valor: ApiNumberParser.toDouble(json['valor']),
      percentualPopulacao:
          ApiNumberParser.toDoubleOrNull(json['percentual_populacao']),
      ordem: FractionalOrder.parse(json['ind_ordem']),
      grupo: json['grupo'] != null
          ? GrupoCensoDto.fromJson(json['grupo'] as Map<String, dynamic>)
          : null,
    );
  }

  factory IndiceCensoDto.fromEntity(
      CensoTitleEntity title, CensoGroupEntity group) {
    return IndiceCensoDto(
      id: title.id,
      nomeEtapa: title.nomeEtapa,
      titulo: title.tituloExibicao,
      valor: title.valor,
      percentualPopulacao: title.percentualPopulacao,
      ordem: title.ordem,
      grupo: GrupoCensoDto.fromEntity(group),
    );
  }
}

class GrupoCensoDto {
  final int id;
  final String nome;
  final FractionalOrder ordem;

  const GrupoCensoDto({
    required this.id,
    required this.nome,
    this.ordem = FractionalOrder.zero,
  });

  factory GrupoCensoDto.fromJson(Map<String, dynamic> json) {
    return GrupoCensoDto(
      id: ApiNumberParser.toInt(json['id']),
      nome: json['nome'] as String? ?? '',
      ordem: FractionalOrder.parse(json['ordem']),
    );
  }

  factory GrupoCensoDto.fromEntity(CensoGroupEntity entity) {
    return GrupoCensoDto(
      id: entity.id,
      nome: entity.nome,
      ordem: entity.ordem,
    );
  }
}

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

  BudgetCensusEntity toEntity() {
    return BudgetCensusEntity(
      orcamentoId: orcamentoId,
      multiCidade: multiCidade,
      cidades: cidades.map((c) => c.toEntity()).toList(),
      censoAgregado: censoAgregado,
    );
  }
}
