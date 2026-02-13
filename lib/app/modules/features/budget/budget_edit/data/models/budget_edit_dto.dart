import '../../../budget_config/data/models/census_data_dto.dart';
import '../../../budget_config/data/models/product_selection_dto.dart';
import '../../domain/entities/budget_edit_entity.dart';

class BudgetEditDto {
  final int id;
  final String? name;
  final int validityDays;
  final DateTime? validityDate;
  final DateTime? creationDate;
  final String status;
  final double total;
  final int userId;
  final int? partnerId;
  final List<int> cityIds;
  final List<Map<String, dynamic>>
      citiesDataRaw;
  final List<ProductSelectionDto> products;
  final dynamic categoriesData;
  final CensusDataDto? censusData;

  final Map<String, double> censoAgregado;

  BudgetEditDto({
    required this.id,
    this.name,
    required this.validityDays,
    this.validityDate,
    this.creationDate,
    required this.status,
    required this.total,
    required this.userId,
    this.partnerId,
    required this.cityIds,
    this.citiesDataRaw = const [],
    required this.products,
    required this.categoriesData,
    this.censusData,
    this.censoAgregado = const {},
  });

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static List<Map<String, dynamic>> _normalizeIndicators(List<dynamic> raw) {
    return raw.whereType<Map>().map((item) {
      final map = Map<String, dynamic>.from(item);
      final group = map['grupo'] as Map<String, dynamic>?;
      final pivot = map['pivot'] as Map<String, dynamic>?;

      final groupId = _toInt(
        map['grupo_id'] ??
            map['grupos_grupo_id'] ??
            group?['id'] ??
            group?['grupo_id'],
      );
      final groupName = (map['grupo_nome'] ??
              group?['nome'] ??
              group?['nome_grupo'] ??
              '')
          .toString();

      return <String, dynamic>{
        'id': _toInt(
          map['id'] ??
              map['idindice_etapa'] ??
              map['indice_etapa_id'] ??
              map['indice_etapa_idindice_etapa'],
        ),
        'nome': (map['nome'] ?? map['nome_etapa'] ?? '').toString(),
        'titulo': (map['titulo'] ??
                map['titulo_etapa'] ??
                map['nome'] ??
                map['nome_etapa'] ??
                '')
            .toString(),
        'valor': _toDouble(
          map['valor'] ?? map['etapa_valor'] ?? pivot?['etapa_valor'],
        ),
        'grupo_id': groupId,
        'grupo_nome': groupName,
      };
    }).toList();
  }

  static Map<String, dynamic> _normalizeCityData(Map<String, dynamic> cityMap) {
    final rawIndicators = cityMap['indices'] as List? ??
        cityMap['indicadores'] as List? ??
        cityMap['cidades_has_indice_etapa'] as List? ??
        const [];
    final indicadores = _normalizeIndicators(rawIndicators);

    final indices = indicadores
        .map(
          (item) => <String, dynamic>{
            'id': item['id'],
            'nome_etapa': item['nome'],
            'titulo': item['titulo'],
            'valor': item['valor'],
            'grupo': {
              'id': item['grupo_id'],
              'nome': item['grupo_nome'],
            },
          },
        )
        .toList();

    return {
      ...cityMap,
      'id': _toInt(cityMap['id'] ?? cityMap['idCidades']),
      'nome': (cityMap['nome'] ?? cityMap['nome_cidade'] ?? '').toString(),
      'indices': indices,
      'indicadores': indicadores,
    };
  }

  factory BudgetEditDto.fromJson(Map<String, dynamic> json) {
    final List<ProductSelectionDto> productsList = [];

    final List<int> cities = [];
    final List<Map<String, dynamic>> citiesData = [];

    if (json['cidades'] != null && json['cidades'] is List) {
      final cidadesList = json['cidades'] as List;
      for (final cidade in cidadesList) {
        if (cidade is Map<String, dynamic> && cidade['id'] != null) {
          final normalized = _normalizeCityData(cidade);
          cities.add(_toInt(normalized['id']));
          citiesData.add(normalized);
        }
        else if (cidade is int) {
          cities.add(cidade);
        }
      }
    } else if (json['cidade'] != null && json['cidade'] is Map) {
      final cidadeMap = json['cidade'] as Map<String, dynamic>;
      final cidadeId = _toInt(cidadeMap['id']);
      final cidadeName = (cidadeMap['nome'] ?? 'Cidade $cidadeId').toString();

      cities.add(cidadeId);

      final normalizedCity = _normalizeCityData({
        ...cidadeMap,
        'id': cidadeId,
        'nome': cidadeName,
      });
      citiesData.add(normalizedCity);
    }

    CensusDataDto? census;
    if (json['censo'] != null) {
      census = CensusDataDto.fromJson(json['censo']);
    }

    Map<String, double> censoAgregado = {};
    final censoAgregadoRaw = json['censo_agregado'];
    if (censoAgregadoRaw is Map<String, dynamic>) {
      censoAgregado = censoAgregadoRaw.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
    }

    return BudgetEditDto(
      id: json['id'] ?? 0,
      name: json['nome'],
      validityDays: json['dias_validade'] ?? 30,
      validityDate: json['data_validade'] != null
          ? DateTime.tryParse(json['data_validade'])
          : null,
      creationDate: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      status: json['status'] ?? 'pendente',
      total: (json['total'] ?? 0.0).toDouble(),
      userId: json['usuario_id'] ?? 0,
      partnerId: json['partner_id'],
      cityIds: cities,
      citiesDataRaw: citiesData,
      products: productsList,
      categoriesData: json['categorias'] ?? [],
      censusData: census,
      censoAgregado: censoAgregado,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (name != null) 'nome': name,
      'orc_dias_validade': validityDays,
      if (validityDate != null)
        'orc_data_validade': validityDate!.toIso8601String(),
      'orc_status': status,
      'orc_total': total,
      'orc_usuario_id': userId,
      if (partnerId != null) 'orc_partner_destino_id': partnerId,
      'cidades': cityIds,
      'produtos': products.map((p) => p.toJson()).toList(),
    };
  }

  BudgetEditEntity toEntity() {
    return BudgetEditEntity(
      id: id,
      name: name,
      validityDays: validityDays,
      validityDate: validityDate,
      creationDate: creationDate,
      status: status,
      total: total,
      userId: userId,
      partnerId: partnerId,
      cityIds: cityIds,
      citiesDataRaw: citiesDataRaw,
      products: products.map((p) => p.toEntity()).toList(),
      categoriesData: categoriesData,
      censusData: censusData?.toEntity(),
      censoAgregado: censoAgregado,
    );
  }

  bool get isArchived => status.toLowerCase() == 'arquivado';
}
