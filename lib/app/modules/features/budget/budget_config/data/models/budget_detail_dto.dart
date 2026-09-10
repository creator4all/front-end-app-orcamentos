import 'package:multimidiaapp/app/shared/domain/value_objects/fractional_order.dart';

import '../../../../../../shared/utils/api_number_parser.dart';
import '../../../shared/models/budget_city_context_dto.dart';
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
  final bool isArchived;

  /// Classificação declarada pelo backend em `multi_cidade`.
  ///
  /// Nula em respostas que ainda não trazem a chave; nesse caso a entidade
  /// deriva a classificação pela quantidade de cidades.
  final bool? multiCity;

  /// Censo agregado do orçamento, vindo de `censo_agregado`.
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
    this.isArchived = false,
    this.multiCity,
    this.censoAgregado = const {},
  });

  /// Constrói o DTO a partir do registro de `GET /api/orcamentos/{id}`.
  ///
  /// A resposta é o orçamento cru (`orc_*`), com o contexto de cidades em
  /// `multi_cidade`/`cidades`/`censo_agregado` e a árvore de produtos em
  /// `orcamento_produtos`.
  factory BudgetDetailDto.fromJson(Map<String, dynamic> json) {
    final List<ProductSelectionDto> productsList = [];

    final Map<String, bool> categoryStates = {};

    final cityContext = BudgetCityContextDto.fromJson(json);

    final List<CategoryDTO> categoriesList = [];
    final orcamentoProdutos = json['orcamento_produtos'];
    if (orcamentoProdutos is List) {
      categoriesList
          .addAll(buildCategoriesFromOrcamentoProdutos(orcamentoProdutos));
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

    final usuarioJson = json['usuario'] as Map<String, dynamic>?;
    final userId = ApiNumberParser.toIntOrNull(usuarioJson?['usr_userId']) ??
        ApiNumberParser.toInt(json['orc_usuario_id']);

    return BudgetDetailDto(
      id: ApiNumberParser.toInt(json['orc_orcamentoId']),
      name: json['orc_nome'] as String?,
      validityDays:
          ApiNumberParser.toIntOrNull(json['orc_dias_validade']) ?? 30,
      validityDate: _parseDate(json['orc_data_validade']),
      creationDate: _parseDate(json['created_at']),
      status: json['orc_status'] as String? ?? 'rascunho',
      total: ApiNumberParser.toDouble(json['orc_total']),
      userId: userId,
      partnerId: ApiNumberParser.toIntOrNull(json['orc_partner_destino_id']),
      cityIds: cityContext.cityIds,
      products: productsList,
      categoryStates: categoryStates,
      categories: categoriesList,
      citiesData: cityContext.citiesData,
      isArchived: json['orc_is_archived'] as bool? ?? false,
      multiCity: cityContext.multiCity,
      censoAgregado: cityContext.censoAgregado,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
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
      isArchived: isArchived,
      multiCity: multiCity,
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
      final catOrdem = FractionalOrder.parse(categoriaJson['cat_ordem']);
      final catExpandido = categoriaJson['cat_expandido'] as bool? ?? true;

      final subId =
          (subcategoriaJson['sub_subcategoriasId'] as num?)?.toInt() ?? 0;
      final subNome = subcategoriaJson['sub_name'] as String? ?? '';
      final subOrdem = FractionalOrder.parse(subcategoriaJson['sub_order']);

      // Build product from the nested produto + orcamento_produto data
      final productJson = Map<String, dynamic>.from(produtoJson);
      // Inject orcamento_produto selection data
      productJson['orcamento_produto'] = {
        'selecionado': op['op_selecionado'] as bool? ?? false,
        'quantidade':
            double.tryParse(op['op_quantidade']?.toString() ?? '0') ?? 0.0,
        'op_quantidade_manual': op['op_quantidade_manual'] as bool? ?? false,
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
      multiCity: entity.multiCity,
      censoAgregado: entity.censoAgregado,
    );
  }
}

/// Helper class to build CategoryDTO from grouped orcamento_produtos
class _CatBuilder {
  final int id;
  final String nome;
  final FractionalOrder ordem;
  final bool expandido;
  final Map<int, _SubBuilder> _subcategorias = {};

  _CatBuilder({
    required this.id,
    required this.nome,
    required this.ordem,
    required this.expandido,
  });

  void addProduct(
      int subId, String subNome, FractionalOrder subOrdem, ProductDTO product) {
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
  final FractionalOrder ordem;
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
