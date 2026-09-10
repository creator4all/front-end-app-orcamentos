import 'package:equatable/equatable.dart';

import '../../../../../shared/utils/api_number_parser.dart';

/// Contexto de cidades de um orçamento, extraído dos contratos de leitura.
///
/// `GET /api/orcamentos/{id}` e `GET /api/orcamentos/novo/{id}` entregam
/// `multi_cidade`, `cidades` e `censo_agregado`. Um orçamento multi-cidade tem
/// `orc_cidade_id` nulo e `cidade` nula, então ler apenas a cidade singular
/// esvazia o contexto e faz o app versionar pelo endpoint errado.
///
/// Este parser existe para que `BudgetDetailDto` e `BudgetEditDto` interpretem
/// o mesmo contrato uma única vez. O endpoint dedicado
/// `GET /api/orcamentos/{id}/censo` é lido por `BudgetCensusDto`
/// (`budget_config/data/models/budget_census_dto.dart`), que produz objetos
/// tipados a partir das mesmas chaves — ao mudar um dos dois, revise o outro.
class BudgetCityContextDto extends Equatable {
  /// Classificação declarada pelo backend (`orc_cidade_id === null`).
  ///
  /// Fica nula quando o payload não traz `multi_cidade`, e nesse caso a
  /// entidade deriva a classificação pela quantidade de cidades.
  final bool? multiCity;

  final List<int> cityIds;
  final List<Map<String, dynamic>> citiesData;
  final Map<String, double> censoAgregado;

  const BudgetCityContextDto({
    this.multiCity,
    required this.cityIds,
    required this.citiesData,
    required this.censoAgregado,
  });

  /// Lê o contexto aceitando o contrato multi-cidade e o legado de cidade única.
  ///
  /// A precedência é `cidades` (plural) → `cidade` (objeto legado) →
  /// `orc_cidade_id` (apenas o ID), de forma que respostas antigas continuem
  /// produzindo um contexto válido de uma cidade.
  factory BudgetCityContextDto.fromJson(Map<String, dynamic> json) {
    final cityIds = <int>[];
    final citiesData = <Map<String, dynamic>>[];

    final rawCities = json['cidades'];
    if (rawCities is List) {
      for (final rawCity in rawCities) {
        if (rawCity is! Map) continue;

        final city = Map<String, dynamic>.from(rawCity);
        final cityId = ApiNumberParser.toInt(
          city['id'] ?? city['idCidades'] ?? city['cidade_id'],
        );

        if (cityId <= 0 || cityIds.contains(cityId)) continue;

        cityIds.add(cityId);
        citiesData.add(_normalizeCity(city, cityId));
      }
    }

    if (cityIds.isEmpty) {
      final rawCity = json['cidade'];
      if (rawCity is Map) {
        final city = Map<String, dynamic>.from(rawCity);
        final cityId = ApiNumberParser.toInt(
          city['id'] ?? city['idCidades'] ?? json['orc_cidade_id'],
        );

        if (cityId > 0) {
          cityIds.add(cityId);
          citiesData.add(_normalizeCity(city, cityId));
        }
      } else {
        final cityId = ApiNumberParser.toInt(json['orc_cidade_id']);
        if (cityId > 0) {
          cityIds.add(cityId);
          citiesData.add(_normalizeCity(const {}, cityId));
        }
      }
    }

    final explicitMultiCity = json['multi_cidade'];

    return BudgetCityContextDto(
      multiCity: explicitMultiCity is bool ? explicitMultiCity : null,
      cityIds: List.unmodifiable(cityIds),
      citiesData: List.unmodifiable(citiesData),
      censoAgregado: Map.unmodifiable(_parseCensoAgregado(json)),
    );
  }

  /// Normaliza uma cidade para o formato consumido pelas entidades e pelo card.
  ///
  /// Os índices são publicados em `indices` e `indicadores` porque widgets e
  /// store aceitam as duas chaves conforme a origem do payload.
  static Map<String, dynamic> _normalizeCity(
    Map<String, dynamic> city,
    int cityId,
  ) {
    final rawIndices = city['indices'] ??
        city['indicadores'] ??
        city['cidades_has_indice_etapa'] ??
        const <dynamic>[];

    final indices = rawIndices is List
        ? rawIndices
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
        : <Map<String, dynamic>>[];

    return {
      ...city,
      'id': cityId,
      'nome': city['nome'] ?? city['nome_cidade'] ?? 'Cidade $cityId',
      'censo_ano': ApiNumberParser.toIntOrNull(city['censo_ano']),
      'ano_populacao': ApiNumberParser.toIntOrNull(city['ano_populacao']),
      'indices': indices,
      'indicadores': indices,
    };
  }

  /// Lê `censo_agregado` tolerando a lista vazia que o PHP emite no lugar de
  /// um mapa sem chaves.
  static Map<String, double> _parseCensoAgregado(Map<String, dynamic> json) {
    final raw = json['censo_agregado'];
    if (raw is! Map) return const {};

    final censo = <String, double>{};
    raw.forEach((key, value) {
      final parsed = ApiNumberParser.toDoubleOrNull(value);
      if (parsed != null) censo[key.toString()] = parsed;
    });

    return censo;
  }

  @override
  List<Object?> get props => [
        multiCity,
        cityIds,
        citiesData,
        censoAgregado,
      ];
}
