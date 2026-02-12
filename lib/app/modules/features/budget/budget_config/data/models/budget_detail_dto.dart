import '../../domain/entities/budget_detail_entity.dart';
import 'category_dto.dart';
import 'product_selection_dto.dart';

/// DTO para detalhes de orçamento
/// Responsável pela conversão JSON <-> Entity
class BudgetDetailDto {
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
  final List<ProductSelectionDto> products;
  final Map<String, bool> categoryStates;
  final List<CategoryDTO> categories;
  final List<Map<String, dynamic>> citiesData;
  final Map<String, double> censoAgregado;

  BudgetDetailDto({
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
    required this.products,
    required this.categoryStates,
    required this.categories,
    required this.citiesData,
    this.censoAgregado = const {},
  });

  /// Cria DTO a partir do JSON da API
  factory BudgetDetailDto.fromJson(Map<String, dynamic> json) {
    final List<ProductSelectionDto> productsList = [];

    final Map<String, bool> categoryStates = {};

    final List<int> cities = [];
    final List<Map<String, dynamic>> citiesDataList = [];

    // Formato canônico: array de objetos em 'cidades'
    if (json['cidades'] != null && json['cidades'] is List) {
      for (final cidade in json['cidades'] as List) {
        if (cidade is Map<String, dynamic>) {
          final cidadeId = cidade['id'] as int;
          cities.add(cidadeId);
          citiesDataList.add({
            'id': cidadeId,
            'nome': cidade['nome'] ?? 'Cidade $cidadeId',
            'indicadores': (cidade['indicadores'] ?? []) as List,
          });
        }
      }
    }
    // Fallback: objeto singular 'cidade' na raiz (contrato canônico single-city)
    else if (json['cidade'] != null && json['cidade'] is Map) {
      final cidadeMap = json['cidade'] as Map<String, dynamic>;
      final cidadeId = cidadeMap['id'] as int;
      cities.add(cidadeId);
      citiesDataList.add({
        'id': cidadeId,
        'nome': cidadeMap['nome'] ?? 'Cidade $cidadeId',
        'indicadores': (cidadeMap['indices'] ?? []) as List,
      });
    } else if (json['cidade_id'] != null) {
      final cidadeId = json['cidade_id'] as int;
      cities.add(cidadeId);
      citiesDataList.add({
        'id': cidadeId,
        'nome': 'Cidade $cidadeId',
        'indicadores': [],
      });
    }

    final List<CategoryDTO> categoriesList = [];
    if (json['categorias'] != null && json['categorias'] is List) {
      categoriesList.addAll(
        (json['categorias'] as List).map(
          (c) => CategoryDTO.fromJson(Map<String, dynamic>.from(c)),
        ),
      );
    }

    // Extrair produtos selecionados da árvore de categorias
    if (categoriesList.isNotEmpty) {
      for (final cat in categoriesList) {
        for (final sub in cat.subcategorias) {
          for (final prod in sub.produtos) {
            if (prod.selecionado) {
              productsList.add(ProductSelectionDto(
                productId: prod.id,
                name: prod.solucao,
                category: cat.nome,
                price: prod.valor,
                isSelected: true,
                quantity: prod.quantidade,
                observacoes: prod.observacoes,
                indicadoresEtapa: prod.indicadoresEtapa
                    .map((ind) => ProductIndicatorDto(
                          produtoIndicadorId: ind.produtoIndicadorId,
                          selecionado: ind.selecionado,
                        ))
                    .toList(),
              ));
            }
          }
        }
      }
    }

    final censoAgregadoJson =
        json['censo_agregado'] as Map<String, dynamic>? ?? {};
    final censoAgregado = censoAgregadoJson.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    final usuarioJson = json['usuario'] as Map<String, dynamic>?;

    return BudgetDetailDto(
      id: json['id'] as int? ?? 0,
      name: json['nome'] as String?,
      validityDays: json['dias_validade'] as int? ?? 30,
      validityDate: json['data_validade'] != null
          ? DateTime.tryParse(json['data_validade'] as String)
          : null,
      creationDate: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      status: json['status'] as String? ?? 'rascunho',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      userId: usuarioJson?['id'] as int? ?? 0,
      partnerId: json['partner_destino_id'] as int?,
      cityIds: cities,
      products: productsList,
      categoryStates: categoryStates,
      categories: categoriesList,
      citiesData: citiesDataList,
      censoAgregado: censoAgregado,
    );
  }

  /// Converte DTO para JSON
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
      'produtos_selecionados': products.map((p) => p.toJson()).toList(),
      'categorias_ativas': categoryStates.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList(),
      'categorias': categories.map((c) => c.toJson()).toList(),
    };
  }

  /// Converte DTO para Entity
  BudgetDetailEntity toEntity() {
    return BudgetDetailEntity(
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
      products: products.map((p) => p.toEntity()).toList(),
      categoryStates: categoryStates,
      categories: categories.map((c) => c.toEntity()).toList(),
      citiesData: citiesData,
      censoAgregado: censoAgregado,
    );
  }

  /// Cria DTO a partir de Entity
  factory BudgetDetailDto.fromEntity(BudgetDetailEntity entity) {
    return BudgetDetailDto(
      id: entity.id,
      name: entity.name,
      validityDays: entity.validityDays,
      validityDate: entity.validityDate,
      creationDate: entity.creationDate,
      status: entity.status,
      total: entity.total,
      userId: entity.userId,
      partnerId: entity.partnerId,
      cityIds: entity.cityIds,
      products: entity.products
          .map((p) => ProductSelectionDto.fromEntity(p))
          .toList(),
      categoryStates: entity.categoryStates,
      categories:
          entity.categories.map((c) => CategoryDTO.fromEntity(c)).toList(),
      citiesData: [], // Não há dados de cidades na entity, apenas IDs
      censoAgregado: entity.censoAgregado,
    );
  }
}
