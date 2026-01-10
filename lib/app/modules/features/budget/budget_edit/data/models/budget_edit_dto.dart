import '../../../budget_config/data/models/census_data_dto.dart';
import '../../../budget_config/data/models/product_selection_dto.dart';
import '../../domain/entities/budget_edit_entity.dart';

/// DTO para edição de orçamento
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
      citiesDataRaw; // Dados completos das cidades com indicadores
  final List<ProductSelectionDto> products;
  final dynamic categoriesData; // Pode ser List ou Map dependendo da API
  final CensusDataDto? censusData;

  /// Dados agregados do censo escolar para orçamentos multi-cidade
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

  factory BudgetEditDto.fromJson(Map<String, dynamic> json) {
    // Parse produtos - NÃO parseamos aqui, virão de /produtos-completos
    final List<ProductSelectionDto> productsList = [];

    // Parse cidades (IDs e dados completos)
    final List<int> cities = [];
    final List<Map<String, dynamic>> citiesData = [];

    if (json['cidades'] != null && json['cidades'] is List) {
      final cidadesList = json['cidades'] as List;
      for (final cidade in cidadesList) {
        // Se é um objeto com 'id', pega o id E os dados completos
        if (cidade is Map<String, dynamic> && cidade['id'] != null) {
          cities.add(cidade['id'] as int);
          citiesData.add(
              Map<String, dynamic>.from(cidade)); // Armazena dados completos
        }
        // Se é um int direto
        else if (cidade is int) {
          cities.add(cidade);
        }
      }
    }
    // ✅ Caso de criação/retorno onde 'cidade' vem como objeto na raiz (singular)
    else if (json['cidade'] != null && json['cidade'] is Map) {
      final cidadeMap = json['cidade'] as Map<String, dynamic>;
      final cidadeId = cidadeMap['idCidades'] ?? json['orc_cidade_id'] as int;
      final cidadeName = cidadeMap['nome_cidade'] ?? 'Cidade $cidadeId';

      cities.add(cidadeId);

      // Extrair indicadores de 'cidades_has_indice_etapa'
      List<dynamic> indicadoresRaw = [];
      if (cidadeMap['cidades_has_indice_etapa'] != null) {
        indicadoresRaw = cidadeMap['cidades_has_indice_etapa'] as List;
      }

      // Mapear para estrutura simplificada de indicadores esperada pelo app
      final indicadores = indicadoresRaw.map((ind) {
        final grupoObj = ind['grupo'] as Map<String, dynamic>?;
        final nomeGrupo = grupoObj?['nome_grupo'] ?? '';
        final idGrupo = grupoObj?['grupo_id'] ?? 0;

        return {
          'id': ind['idindice_etapa'],
          'nome': ind['nome_etapa'],
          'titulo': ind['titulo_etapa'],
          'valor': ind['pivot']?['etapa_valor'] ?? 0,
          'grupo_id': idGrupo,
          'grupo_nome': nomeGrupo,
        };
      }).toList();

      // Armazenar dados completos da cidade com ambos formatos (raw e simplificado)
      citiesData.add({
        ...cidadeMap, // Dados completos para _parseCensoEscolarFromCitiesData
        'id': cidadeId,
        'nome': cidadeName,
        'indicadores':
            indicadores, // Formato simplificado para SchoolCensusCard
      });
    } else if (json['orc_cidade_id'] != null) {
      cities.add(json['orc_cidade_id'] as int);
    }

    // Parse censo
    CensusDataDto? census;
    if (json['censo'] != null) {
      census = CensusDataDto.fromJson(json['censo']);
    }

    // ✅ Parse censo_agregado para orçamentos multi-cidade
    final censoAgregadoJson =
        json['censo_agregado'] as Map<String, dynamic>? ?? {};
    final censoAgregado = censoAgregadoJson.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );
    if (censoAgregado.isNotEmpty) {
      print(
          '✅ [BudgetEditDTO] censo_agregado parseado: ${censoAgregado.length} etapas');
    }

    return BudgetEditDto(
      id: json['orc_orcamentoId'] ?? 0,
      name: json['nome'] ?? json['orc_nome'],
      validityDays: json['orc_dias_validade'] ?? json['dias_validade'] ?? 30,
      validityDate: json['orc_data_validade'] != null
          ? DateTime.tryParse(json['orc_data_validade'])
          : null,
      creationDate: json['orc_data_criacao'] != null
          ? DateTime.tryParse(json['orc_data_criacao'])
          : (json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null),
      status: json['orc_status'] ?? json['status'] ?? 'pendente',
      total: (json['orc_total'] ?? json['total'] ?? 0.0).toDouble(),
      userId: json['orc_usuario_id'] ?? json['usuario_id'] ?? 0,
      partnerId: json['orc_partner_destino_id'] ?? json['partner_id'],
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

  /// Computed property para compatibilidade com código existente
  bool get isArchived => status.toLowerCase() == 'arquivado';
}
