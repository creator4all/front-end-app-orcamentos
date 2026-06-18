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
  final List<Map<String, dynamic>> citiesDataRaw;
  final List<ProductSelectionDto> products;
  final dynamic categoriesData;
  final CensusDataDto? censusData;
  final bool isArchived;

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
    this.isArchived = false,
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

  /// Agrupa a lista achatada `produtos` em categorias/subcategorias no formato
  /// que `CategoryDTO.fromJson` consome (cat_*/sub_* com `produtos` aninhados).
  /// Os itens de produto seguem crus, pois `ProductDTO.fromJson` já os entende.
  static List<Map<String, dynamic>> _buildCategoriesData(
    List<Map<String, dynamic>> produtos,
  ) {
    final categorias = <int, Map<String, dynamic>>{};
    final subcategoriasPorCategoria = <int, Map<int, Map<String, dynamic>>>{};

    for (final produto in produtos) {
      final subcategoria = produto['subcategoria'] as Map<String, dynamic>?;
      if (subcategoria == null) continue;
      final categoria = subcategoria['categoria'] as Map<String, dynamic>?;
      if (categoria == null) continue;

      final catId = _toInt(categoria['cat_categoriaId']);
      final subId = _toInt(subcategoria['sub_subcategoriasId']);

      categorias.putIfAbsent(
        catId,
        () => <String, dynamic>{
          'cat_categoriaId': catId,
          'cat_nome': categoria['cat_nome'],
          'cat_ordem': _toInt(categoria['cat_ordem']),
          'cat_expandido': categoria['cat_expandido'] ?? true,
          'subcategorias': <Map<String, dynamic>>[],
        },
      );

      final subs = subcategoriasPorCategoria.putIfAbsent(catId, () => {});
      final sub = subs.putIfAbsent(subId, () {
        final novaSub = <String, dynamic>{
          'sub_subcategoriasId': subId,
          'sub_name': subcategoria['sub_name'],
          'sub_order': _toInt(subcategoria['sub_order']),
          'produtos': <Map<String, dynamic>>[],
        };
        (categorias[catId]!['subcategorias'] as List).add(novaSub);
        return novaSub;
      });

      (sub['produtos'] as List).add(produto);
    }

    final lista = categorias.values.toList()
      ..sort(
          (a, b) => (a['cat_ordem'] as int).compareTo(b['cat_ordem'] as int));

    for (final categoria in lista) {
      final subs = (categoria['subcategorias'] as List)
          .cast<Map<String, dynamic>>()
        ..sort(
            (a, b) => (a['sub_order'] as int).compareTo(b['sub_order'] as int));
      for (final sub in subs) {
        (sub['produtos'] as List).cast<Map<String, dynamic>>().sort(
            (a, b) => _toInt(a['pro_ordem']).compareTo(_toInt(b['pro_ordem'])));
      }
    }

    return lista;
  }

  /// Constrói a lista de produtos selecionados (usada pelos helpers do store).
  static List<ProductSelectionDto> _buildSelectedProducts(
    List<Map<String, dynamic>> produtos,
  ) {
    final selecionados = <ProductSelectionDto>[];

    for (final produto in produtos) {
      final orcamentoProduto =
          produto['orcamento_produto'] as Map<String, dynamic>?;
      if (orcamentoProduto == null) continue;
      if (_toInt(orcamentoProduto['op_selecionado']) != 1) continue;

      final subcategoria = produto['subcategoria'] as Map<String, dynamic>?;
      final categoria = subcategoria?['categoria'] as Map<String, dynamic>?;

      final indicadores = (produto['indicadores'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(
                (ind) => ProductIndicatorDto(
                  produtoIndicadorId: _toInt(ind['prd_produtos_indicadoresId']),
                  selecionado: ind['prd_valor'] == true,
                ),
              )
              .toList() ??
          const <ProductIndicatorDto>[];

      selecionados.add(
        ProductSelectionDto(
          productId: _toInt(produto['pro_produtosId']),
          name: (produto['pro_solucao'] ?? '') as String,
          category: (categoria?['cat_nome'] ?? '') as String,
          price: _toDouble(orcamentoProduto['op_valor']),
          isSelected: true,
          quantity: _toDouble(orcamentoProduto['op_quantidade']),
          indicadoresEtapa: indicadores,
        ),
      );
    }

    return selecionados;
  }

  /// Monta, para cada produto, a lista completa de indicadores a partir do
  /// `mapa_indicadores` global. Os indicadores que já vêm no produto ficam
  /// marcados como selecionados (preservando `prd_produtos_indicadoresId`); os
  /// demais entram desmarcados (`produtoIndicadorId = 0`), permitindo ao usuário
  /// marcar/desmarcar. A lista é ordenada por grupo (`gru_ordem`) e, dentro do
  /// grupo, por etapa (`ine_ordem`), e o `indicador_etapa` é injetado no formato
  /// que `ProductDTO.fromJson` consome.
  static void _mergeIndicadores(
    List<Map<String, dynamic>> produtos,
    Map<String, dynamic> mapaIndicadores,
  ) {
    final etapasOrdenadas =
        mapaIndicadores.values.whereType<Map<String, dynamic>>().toList()
          ..sort((a, b) {
            final ordemGrupoA =
                _toInt((a['grupo'] as Map<String, dynamic>?)?['gru_ordem']);
            final ordemGrupoB =
                _toInt((b['grupo'] as Map<String, dynamic>?)?['gru_ordem']);
            if (ordemGrupoA != ordemGrupoB) {
              return ordemGrupoA.compareTo(ordemGrupoB);
            }
            return _toInt(a['ine_ordem']).compareTo(_toInt(b['ine_ordem']));
          });

    for (final produto in produtos) {
      final selecionadosPorEtapa = <int, Map<String, dynamic>>{};
      final indicadoresOriginais = produto['indicadores'];
      if (indicadoresOriginais is List) {
        for (final ind in indicadoresOriginais) {
          if (ind is Map<String, dynamic>) {
            selecionadosPorEtapa[
                _toInt(ind['indicadores_etapa_ine_indicadoresId'])] = ind;
          }
        }
      }

      produto['indicadores'] = etapasOrdenadas.map((etapa) {
        final ineId = _toInt(etapa['ine_indicadoresId']);
        final original = selecionadosPorEtapa[ineId];
        return <String, dynamic>{
          'prd_produtos_indicadoresId':
              _toInt(original?['prd_produtos_indicadoresId']),
          'prd_valor': original != null && original['prd_valor'] == true,
          'indicadores_etapa_ine_indicadoresId': ineId,
          'indicador_etapa': etapa,
        };
      }).toList();
    }
  }

  factory BudgetEditDto.fromJson(Map<String, dynamic> json) {
    final produtos = (json['produtos'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        const <Map<String, dynamic>>[];

    final mapaIndicadores = json['mapa_indicadores'] as Map<String, dynamic>?;
    if (mapaIndicadores != null) {
      _mergeIndicadores(produtos, mapaIndicadores);
    }

    final cities = <int>[];
    final citiesData = <Map<String, dynamic>>[];
    final cidade = json['cidade'];
    if (cidade is Map<String, dynamic>) {
      cities.add(_toInt(cidade['idCidades']));
      citiesData.add(cidade);
    }

    return BudgetEditDto(
      id: _toInt(json['orc_orcamentoId']),
      name: json['orc_nome'] as String?,
      validityDays: _toInt(json['orc_dias_validade']),
      validityDate: json['orc_data_validade'] != null
          ? DateTime.tryParse(json['orc_data_validade'] as String)
          : null,
      creationDate: null,
      status: (json['orc_status'] as String?) ?? 'pendente',
      total: _toDouble(json['orc_total']),
      userId: _toInt(json['orc_usuario_id']),
      partnerId: json['orc_partner_destino_id'] != null
          ? _toInt(json['orc_partner_destino_id'])
          : null,
      cityIds: cities,
      citiesDataRaw: citiesData,
      products: _buildSelectedProducts(produtos),
      categoriesData: _buildCategoriesData(produtos),
      censusData: null,
      isArchived: false,
      censoAgregado: const {},
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
      isArchived: isArchived,
    );
  }
}
