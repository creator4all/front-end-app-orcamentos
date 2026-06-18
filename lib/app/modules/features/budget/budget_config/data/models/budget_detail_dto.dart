import '../../domain/entities/budget_detail_entity.dart';
import 'category_dto.dart';
import 'product_dto.dart';
import 'product_selection_dto.dart';
import 'subcategory_dto.dart';

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

  factory BudgetDetailDto.fromJson(Map<String, dynamic> json) {
    final List<ProductSelectionDto> productsList = [];

    final Map<String, bool> categoryStates = {};

    final List<int> cities = [];
    final List<Map<String, dynamic>> citiesDataList = [];

    if (json['cidades'] != null && json['cidades'] is List) {
      for (final cidade in json['cidades'] as List) {
        if (cidade is Map<String, dynamic>) {
          final cidadeId = (cidade['idCidades'] as num?)?.toInt() ??
              (cidade['id'] as num?)?.toInt() ??
              0;
          final indicadores = (cidade['indices'] ??
              cidade['indicadores'] ??
              cidade['cidades_has_indice_etapa'] ??
              []) as List;
          cities.add(cidadeId);
          citiesDataList.add({
            'id': cidadeId,
            'nome':
                cidade['nome_cidade'] ?? cidade['nome'] ?? 'Cidade $cidadeId',
            'indices': indicadores,
            'indicadores': indicadores,
          });
        }
      }
    } else if (json['cidade'] != null && json['cidade'] is Map) {
      final cidadeMap = json['cidade'] as Map<String, dynamic>;
      final cidadeId = (cidadeMap['idCidades'] as num?)?.toInt() ??
          (cidadeMap['id'] as num?)?.toInt() ??
          0;
      final indicadores = (cidadeMap['indices'] ??
          cidadeMap['indicadores'] ??
          cidadeMap['cidades_has_indice_etapa'] ??
          []) as List;
      cities.add(cidadeId);
      citiesDataList.add({
        'id': cidadeId,
        'nome':
            cidadeMap['nome_cidade'] ?? cidadeMap['nome'] ?? 'Cidade $cidadeId',
        'indices': indicadores,
        'indicadores': indicadores,
      });
    } else if (json['orc_cidade_id'] != null || json['cidade_id'] != null) {
      final cidadeId = (json['orc_cidade_id'] as num?)?.toInt() ??
          (json['cidade_id'] as num?)?.toInt() ??
          0;
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
    } else if (json['orcamento_produtos'] != null &&
        json['orcamento_produtos'] is List) {
      // Build categories hierarchy from orcamento_produtos (new API format)
      categoriesList.addAll(buildCategoriesFromOrcamentoProdutos(
          json['orcamento_produtos'] as List));
    }

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

    // Support prefixed user fields (usr_userId)
    final userId = (usuarioJson?['usr_userId'] as num?)?.toInt() ??
        (usuarioJson?['id'] as num?)?.toInt() ??
        (json['orc_usuario_id'] as num?)?.toInt() ??
        0;

    return BudgetDetailDto(
      id: (json['orc_orcamentoId'] as num?)?.toInt() ??
          (json['id'] as num?)?.toInt() ??
          0,
      name: json['orc_nome'] as String? ?? json['nome'] as String?,
      validityDays: (json['orc_dias_validade'] as num?)?.toInt() ??
          (json['dias_validade'] as num?)?.toInt() ??
          30,
      validityDate: (json['orc_data_validade'] ?? json['data_validade']) != null
          ? DateTime.tryParse(
              (json['orc_data_validade'] ?? json['data_validade']) as String)
          : null,
      creationDate: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      status: json['orc_status'] as String? ??
          json['status'] as String? ??
          'rascunho',
      total: double.tryParse(
              (json['orc_total'] ?? json['total'])?.toString() ?? '0') ??
          0.0,
      userId: userId,
      partnerId: (json['orc_partner_destino_id'] as num?)?.toInt() ??
          (json['partner_destino_id'] as num?)?.toInt(),
      cityIds: cities,
      products: productsList,
      categoryStates: categoryStates,
      categories: categoriesList,
      citiesData: citiesDataList,
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
      'produtos_selecionados': products.map((p) => p.toJson()).toList(),
      'categorias_ativas': categoryStates.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList(),
      'categorias': categories.map((c) => c.toJson()).toList(),
    };
  }

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

  /// Builds the categories hierarchy from orcamento_produtos array.
  /// The new API returns products with nested subcategoria.categoria
  /// instead of a flat categorias array.
  static List<CategoryDTO> buildCategoriesFromOrcamentoProdutos(
      List orcamentoProdutos) {
    // Map: categoriaId -> { categoria info, subcategorias map }
    final Map<int, _CatBuilder> catMap = {};

    for (final op in orcamentoProdutos) {
      if (op is! Map<String, dynamic>) continue;
      final produtoJson = op['produto'] as Map<String, dynamic>?;
      if (produtoJson == null) continue;

      final subcategoriaJson =
          produtoJson['subcategoria'] as Map<String, dynamic>?;
      if (subcategoriaJson == null) continue;

      final categoriaJson =
          subcategoriaJson['categoria'] as Map<String, dynamic>?;
      if (categoriaJson == null) continue;

      final catId = (categoriaJson['cat_categoriaId'] as num?)?.toInt() ?? 0;
      final catNome = categoriaJson['cat_nome'] as String? ?? '';
      final catOrdem = (categoriaJson['cat_ordem'] as num?)?.toInt() ?? 0;
      final catExpandido = categoriaJson['cat_expandido'] as bool? ?? true;

      final subId =
          (subcategoriaJson['sub_subcategoriasId'] as num?)?.toInt() ?? 0;
      final subNome = subcategoriaJson['sub_name'] as String? ?? '';
      final subOrdem = (subcategoriaJson['sub_order'] as num?)?.toInt() ?? 0;

      // Build product from the nested produto + orcamento_produto data
      final productJson = Map<String, dynamic>.from(produtoJson);
      // Inject orcamento_produto selection data
      productJson['orcamento_produto'] = {
        'selecionado': op['op_selecionado'] as bool? ?? false,
        'quantidade':
            double.tryParse(op['op_quantidade']?.toString() ?? '0') ?? 0.0,
      };

      // Check for overrides
      final overrides = op['overrides_do_orcamento'] as List?;
      if (overrides != null && overrides.isNotEmpty) {
        productJson['tem_override'] = true;
        // Apply override values
        for (final ovr in overrides) {
          if (ovr is Map<String, dynamic>) {
            if (ovr['opo_tipo_override'] == 'produto_completo') {
              if (ovr['opo_valor_override'] != null) {
                productJson['pro_valor'] = ovr['opo_valor_override'];
              }
              if (ovr['opo_ativo_override'] != null) {
                productJson['pro_ativo'] = ovr['opo_ativo_override'];
              }
            }
          }
        }
      }

      final product = ProductDTO.fromJson(productJson);

      // Add to category map
      catMap.putIfAbsent(
          catId,
          () => _CatBuilder(
                id: catId,
                nome: catNome,
                ordem: catOrdem,
                expandido: catExpandido,
              ));

      catMap[catId]!.addProduct(subId, subNome, subOrdem, product);
    }

    // Convert map to sorted list of CategoryDTO
    final result = catMap.values.map((builder) => builder.build()).toList();
    result.sort((a, b) => a.ordem.compareTo(b.ordem));
    return result;
  }

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
      citiesData: [],
      censoAgregado: entity.censoAgregado,
    );
  }
}

/// Helper class to build CategoryDTO from grouped orcamento_produtos
class _CatBuilder {
  final int id;
  final String nome;
  final int ordem;
  final bool expandido;
  final Map<int, _SubBuilder> _subcategorias = {};

  _CatBuilder({
    required this.id,
    required this.nome,
    required this.ordem,
    required this.expandido,
  });

  void addProduct(int subId, String subNome, int subOrdem, ProductDTO product) {
    _subcategorias.putIfAbsent(
        subId,
        () => _SubBuilder(
              id: subId,
              nome: subNome,
              ordem: subOrdem,
            ));
    _subcategorias[subId]!.produtos.add(product);
  }

  CategoryDTO build() {
    final subs = _subcategorias.values.map((sb) => sb.build()).toList();
    subs.sort((a, b) => a.ordem.compareTo(b.ordem));
    return CategoryDTO(
      id: id,
      nome: nome,
      ordem: ordem,
      expandido: expandido,
      subcategorias: subs,
    );
  }
}

/// Helper class to build SubcategoryDTO
class _SubBuilder {
  final int id;
  final String nome;
  final int ordem;
  final List<ProductDTO> produtos = [];

  _SubBuilder({
    required this.id,
    required this.nome,
    required this.ordem,
  });

  SubcategoryDTO build() {
    final sorted = List<ProductDTO>.from(produtos);
    sorted.sort((a, b) => a.ordem.compareTo(b.ordem));
    return SubcategoryDTO(
      id: id,
      nome: nome,
      ordem: ordem,
      produtos: sorted,
    );
  }
}
