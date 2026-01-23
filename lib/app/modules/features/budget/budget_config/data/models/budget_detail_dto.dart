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
  final List<Map<String, dynamic>>
      citiesData; // ✅ Dados completos das cidades com indicadores
  final Map<String, double>
      censoAgregado; // ✅ Censo agregado para orçamentos multi-cidade

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
    // Parse produtos
    final List<ProductSelectionDto> productsList = [];

    // 1. Tenta formato 'orcamentoProdutos' / 'orcamento_produtos' (Estrutura completa do PHP/Eloquent)
    final orcProdutos = json['orcamentoProdutos'] ?? json['orcamento_produtos'];
    if (orcProdutos != null && orcProdutos is List) {
      for (final item in orcProdutos) {
        if (item is Map<String, dynamic>) {
          final prod = item['produto'] as Map<String, dynamic>? ?? {};
          final sub = prod['subcategoria'] as Map<String, dynamic>? ?? {};
          final cat = sub['categoria'] as Map<String, dynamic>? ?? {};

          // Parse indicadores selecionados do pivô ou do produto se necessário
          // Por enquanto, deixamos vazio pois o foco aqui é a lista de seleção
          // A extração completa de indicadores acontece via ProductDTO nas categorias

          productsList.add(ProductSelectionDto(
            productId: item['op_produto_id'] ??
                prod['pro_produtosId'] ??
                item['op_produto_id'] ??
                0,
            name: prod['pro_solucao'] ?? prod['solucao'] ?? '',
            category: cat['cat_nome'] ?? cat['nome'] ?? '',
            price: (prod['pro_valor'] ?? prod['valor'] ?? 0).toDouble(),
            isSelected:
                item['op_selecionado'] == 1 || item['op_selecionado'] == true,
            quantity: item['op_quantidade'] ?? 0,
            indicadoresEtapa: [],
          ));
        }
      }
    }
    // 2. Formatos simplificados antigos
    else if (json['produtos'] != null && json['produtos'] is List) {
      productsList.addAll(
        (json['produtos'] as List).map(
          (p) => ProductSelectionDto.fromJson(Map<String, dynamic>.from(p)),
        ),
      );
    } else if (json['produtos_selecionados'] != null &&
        json['produtos_selecionados'] is List) {
      productsList.addAll(
        (json['produtos_selecionados'] as List).map(
          (p) => ProductSelectionDto.fromJson(Map<String, dynamic>.from(p)),
        ),
      );
    }

    // Parse estados de categorias
    final Map<String, bool> categories = {};
    if (json['categorias'] != null && json['categorias'] is Map) {
      (json['categorias'] as Map).forEach((key, value) {
        categories[key.toString()] = value == true || value == 1;
      });
    } else if (json['categorias_ativas'] != null &&
        json['categorias_ativas'] is List) {
      for (final cat in json['categorias_ativas']) {
        categories[cat.toString()] = true;
      }
    }

    // Parse cidades
    final List<int> cities = [];
    final List<Map<String, dynamic>> citiesDataList = [];

    if (json['cidades'] != null && json['cidades'] is List) {
      print('🔍 [BudgetDetailDTO] Parseando cidades...');
      for (final cidade in json['cidades'] as List) {
        if (cidade is int) {
          // Cidade é um ID simples
          cities.add(cidade);
          print('   ✅ Cidade ID: $cidade');
          citiesDataList.add({
            'id': cidade,
            'nome': 'Cidade $cidade',
            'indicadores': [],
          });
        } else if (cidade is Map<String, dynamic>) {
          // Cidade é um objeto com {id, nome, indicadores}
          final cidadeId = cidade['id'] as int;
          cities.add(cidadeId);
          final cidadeName = cidade['nome'] ?? 'Cidade $cidadeId';
          final indicadores = (cidade['indicadores'] ?? []) as List;

          print('   ✅ Cidade: $cidadeName (ID: $cidadeId)');
          print('      📊 Indicadores: ${indicadores.length}');

          citiesDataList.add({
            'id': cidadeId,
            'nome': cidadeName,
            'indicadores': indicadores,
          });
        }
      }
      print('✅ [BudgetDetailDTO] Total de cidades: ${cities.length}');
    } else if (json['cidade'] != null && json['cidade'] is Map) {
      // ✅ Caso de criação/retorno simples onde 'cidade' vem como objeto na raiz
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
        // Tenta extrair grupo
        final grupoObj = ind['grupo'] as Map<String, dynamic>?;
        final nomeGrupo = grupoObj?['nome_grupo'] ?? '';
        final idGrupo = grupoObj?['grupo_id'] ?? 0;

        // Parsear etapa_valor como double (API retorna String "305.00")
        final valorRaw = ind['pivot']?['etapa_valor'] ?? 0;
        final valor = valorRaw is num
            ? valorRaw.toDouble()
            : double.tryParse(valorRaw.toString()) ?? 0.0;

        return {
          'id': ind['idindice_etapa'],
          'nome': ind['nome_etapa'],
          'valor': valor,
          'grupo_id': idGrupo,
          'grupo_nome': nomeGrupo,
        };
      }).toList();

      print(
          '✅ [BudgetDetailDTO] Cidade extraída do root: $cidadeName (ID: $cidadeId)');
      print('   📊 Indicadores com grupo: ${indicadores.length}');

      citiesDataList.add({
        'id': cidadeId,
        'nome': cidadeName,
        'indicadores': indicadores,
      });
    } else if (json['orc_cidade_id'] != null) {
      cities.add(json['orc_cidade_id'] as int);
      citiesDataList.add({
        'id': json['orc_cidade_id'] as int,
        'nome': 'Cidade ${json['orc_cidade_id']}',
        'indicadores': [],
      });
    }

    // ✅ Parse categorias com subcategorias e produtos
    final List<CategoryDTO> categoriesList = [];
    if (json['categorias'] != null && json['categorias'] is List) {
      print(
          '🔍 [BudgetDetailDTO] Parseando ${(json['categorias'] as List).length} categorias...');
      categoriesList.addAll(
        (json['categorias'] as List).map(
          (c) => CategoryDTO.fromJson(Map<String, dynamic>.from(c)),
        ),
      );
      print(
          '✅ [BudgetDetailDTO] ${categoriesList.length} categorias parseadas');
    } else {
      print('⚠️ [BudgetDetailDTO] Nenhuma categoria encontrada no JSON!');
    }

    // 🆕 FALLBACK: Se productsList estiver vazia, tentar extrair da árvore de categorias
    if (productsList.isEmpty && categoriesList.isNotEmpty) {
      print(
          '⚠️ [BudgetDetailDTO] Lista de produtos vazia na raiz, extraindo das categorias...');
      for (final cat in categoriesList) {
        for (final sub in cat.subcategorias) {
          for (final prod in sub.produtos) {
            if (prod.selecionado) {
              // Converter ProductDTO para ProductSelectionDto
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
      print(
          '✅ [BudgetDetailDTO] ${productsList.length} produtos extraídos das categorias.');
    }

    // ✅ Parse censo_agregado para orçamentos multi-cidade
    final censoAgregadoJson =
        json['censo_agregado'] as Map<String, dynamic>? ?? {};
    final censoAgregado = censoAgregadoJson.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );
    if (censoAgregado.isNotEmpty) {
      print(
          '✅ [BudgetDetailDTO] censo_agregado parseado: ${censoAgregado.length} etapas');
    }

    return BudgetDetailDto(
      id: json['id'] ?? 0,
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
      status: json['orc_status'] ?? json['status'] ?? 'rascunho',
      total: (json['orc_total'] ?? json['total'] ?? 0.0).toDouble(),
      userId: json['orc_usuario_id'] ?? json['usuario_id'] ?? 0,
      partnerId: json['orc_partner_destino_id'] ?? json['partner_id'],
      cityIds: cities,
      products: productsList,
      categoryStates: categories,
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
