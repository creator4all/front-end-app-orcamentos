import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

import '../../../budget_create/domain/entities/budget_draft_entity.dart';
import '../../../budget_create/domain/entities/cidade_entity.dart';
import '../../../shared/errors/budget_failure.dart';
import '../../../shared/models/budget_update_dto.dart';
import '../../../shared/models/product_selection_update_dto.dart';
import '../../domain/entities/budget_detail_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/censo_escolar_entity.dart';
import '../../domain/entities/censo_group_entity.dart';
import '../../domain/entities/censo_title_entity.dart';
import '../../domain/entities/census_data_entity.dart';
import '../../domain/entities/indicador_etapa_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/subcategory_entity.dart';
import '../../domain/services/product_calculation_service.dart';
import '../../domain/usecases/calculate_totals_usecase.dart';
import '../../domain/usecases/finalize_budget_usecase.dart';
import '../../domain/usecases/get_all_budget_products_usecase.dart';
import '../../domain/usecases/get_budget_detail_usecase.dart';
import '../../domain/usecases/get_category_products_usecase.dart';
import '../../domain/usecases/get_census_data_usecase.dart';
import '../../domain/usecases/save_budget_usecase.dart';
import '../../domain/usecases/toggle_category_usecase.dart';

part 'budget_config_store.g.dart';

class BudgetConfigStore = _BudgetConfigStoreBase with _$BudgetConfigStore;

abstract class _BudgetConfigStoreBase with Store {
  final GetBudgetDetailUseCase getBudgetDetailUseCase;
  final GetAllBudgetProductsUseCase getAllBudgetProductsUseCase;
  final GetCategoryProductsUseCase getCategoryProductsUseCase;
  final GetCensusDataUseCase getCensusDataUseCase;
  final ToggleCategoryUseCase toggleCategoryUseCase;
  final CalculateTotalsUseCase calculateTotalsUseCase;
  final FinalizeBudgetUseCase finalizeBudgetUseCase;
  final SaveBudgetUseCase saveBudgetUseCase;
  final ProductCalculationService calculationService;

  _BudgetConfigStoreBase({
    required this.getBudgetDetailUseCase,
    required this.getAllBudgetProductsUseCase,
    required this.getCategoryProductsUseCase,
    required this.getCensusDataUseCase,
    required this.toggleCategoryUseCase,
    required this.calculateTotalsUseCase,
    required this.finalizeBudgetUseCase,
    required this.saveBudgetUseCase,
    required this.calculationService,
  });

  // ========== OBSERVABLES ==========

  @observable
  bool isLoading = false;

  @observable
  bool isLoadingProducts = false;

  @observable
  bool isLoadingCensus = false;

  @observable
  bool isSaving = false;

  @observable
  String? error;

  @observable
  BudgetDetailEntity? budgetDetail;

  @observable
  CensusDataEntity? censusData;

  @observable
  CensoEscolarEntity? censoEscolar;

  @observable
  ObservableMap<String, bool> categoryStates = ObservableMap<String, bool>();

  @observable
  DateTime? validityDate;

  @observable
  String? budgetName;

  // ✅ Novos observables para categorias
  @observable
  ObservableList<CategoryEntity> categories = ObservableList<CategoryEntity>();

  @observable
  CategoryEntity? selectedCategory;

  @observable
  SubcategoryEntity? selectedSubcategory;

  // ✅ Produtos que precisam de remarcação após mudança no censo
  @observable
  List<ProductEntity> productsNeedingRemark = [];

  // ========== COMPUTED ==========

  @computed
  bool get canFinalize {
    if (budgetDetail == null) return false;
    if (validityDate == null) return false;

    // ✅ Verificar se tem produtos selecionados nas categorias
    return totalSelectedProducts > 0;
  }

  @computed
  int get selectedCategoriesCount {
    return categories.where((c) => c.hasSelectedProducts).length;
  }

  @computed
  double get totalValue {
    // ✅ Calcular total a partir das categorias
    return categories.fold(0.0, (sum, c) => sum + c.totalValue);
  }

  @computed
  int get selectedProductsCount {
    // ✅ Contar produtos selecionados nas categorias
    return categories.fold(0, (sum, c) => sum + c.selectedProductsCount);
  }

  // ✅ Novo computed para total de produtos ativos
  @computed
  int get totalActiveProducts {
    return categories.fold(0, (sum, c) => sum + c.totalActiveProducts);
  }

  // ✅ Novo computed para total de produtos selecionados
  @computed
  int get totalSelectedProducts {
    return categories.fold(0, (sum, c) => sum + c.selectedProductsCount);
  }

  // ✅ Contagem corrigida: expandidas contam subcategorias selecionadas, compactas contam produtos individuais
  @computed
  int get selectedItemsCount {
    return categories.fold(0, (sum, category) {
      if (category.expandido) {
        // Categorias expandidas contam SUBCATEGORIAS com produtos selecionados
        final selectedSubcategories = category.subcategorias
            .where((subcategory) => subcategory.hasSelectedProducts)
            .length;
        return sum + selectedSubcategories;
      } else {
        // Categorias compactas contam como 1 categoria se tiverem produtos selecionados
        return sum + (category.hasSelectedProducts ? 1 : 0);
      }
    });
  }

  @computed
  bool get hasData => budgetDetail != null;

  @computed
  bool get hasCensusData => censusData != null && censusData!.hasData;

  // ✅ Novo computed para verificar se tem categorias
  @computed
  bool get hasCategories => categories.isNotEmpty;

  @computed
  bool get isFullyLoaded => !isLoading && !isLoadingProducts;

  // ========== ACTIONS ==========

  @action
  Future<void> initialize(int budgetId) async {
    await loadBudgetDetail(budgetId);

    // Carregar censo se tiver cidade
    if (budgetDetail != null && budgetDetail!.cityIds.isNotEmpty) {
      await loadCensusData(budgetDetail!.cityIds.first);
    }
  }

  @action
  Future<void> initializeWithDraft(BudgetDraftEntity draft) async {
    isLoading = true;
    isLoadingProducts = false;
    error = null;

    try {
      budgetDetail = BudgetDetailEntity(
        id: draft.id,
        name: draft.partnerName,
        validityDays: draft.validityDays,
        validityDate: draft.validityDate,
        creationDate: draft.createdAt,
        status: draft.status,
        total: draft.total,
        userId: draft.createdByUserId,
        partnerId: draft.partnerId,
        cityIds:
            [draft.location.cityCode].map((e) => int.tryParse(e) ?? 0).toList(),
        products: const [],
        categoryStates: const {},
        categories: draft.categories,
        citiesData: _extractCitiesDataFromDraft(draft),
      );

      categories.clear();
      categories.addAll(draft.categories);

      categoryStates.clear();

      validityDate =
          draft.validityDate ?? DateTime.now().add(const Duration(days: 60));
      budgetName = draft.partnerName;

      // 🧮 Preencher censoEscolar a partir dos dados da cidade
      final oldCensoEscolar = censoEscolar;
      censoEscolar = _convertCidadeToCensoEscolar(draft.cidade);

      // 🔄 Verificar se houve mudança no censo que afeta produtos
      if (oldCensoEscolar != null && censoEscolar != null) {
        _checkForProductsToRemark(oldCensoEscolar, censoEscolar!);
      }

      isLoading = false;

      if (draft.location.cityCode.isNotEmpty) {
        final cityId = int.tryParse(draft.location.cityCode);
        if (cityId != null && cityId > 0) {
          await loadCensusData(cityId);
        }
      }
    } catch (e) {
      error = 'Erro ao inicializar orçamento: $e';
      isLoading = false;
    }
  }

  /// Extrai dados das cidades do draft para formato esperado pelo SchoolCensusCard
  List<Map<String, dynamic>> _extractCitiesDataFromDraft(
      BudgetDraftEntity draft) {
    if (draft.cidade == null) return [];

    final cidade = draft.cidade!;
    return [
      {
        'id': cidade.id,
        'nome': cidade.nome,
        'indicadores': cidade.cidadesHasIndiceEtapa
            .map((etapa) => {
                  'nome': etapa.nomeEtapa,
                  'valor': etapa.etapaValor.toInt(),
                })
            .toList(),
      }
    ];
  }

  /// Sincroniza o estado de seleção do produto com base na quantidade
  /// Se quantidade = 0 → selecionado = false
  /// Se quantidade > 0 → selecionado = true
  ProductEntity _synchronizeProductSelection(ProductEntity product) {
    final shouldBeSelected = product.quantidade > 0;

    if (product.selecionado != shouldBeSelected) {
      print(
          '🔄 [BudgetConfigStore] Sincronizando produto "${product.solucao}": '
          'quantidade=${product.quantidade}, selecionado=${product.selecionado} → $shouldBeSelected');

      return product.copyWith(selecionado: shouldBeSelected);
    }

    return product;
  }

  /// Converte CidadeEntity para CensoEscolarEntity
  /// Necessário para o cálculo de quantidades baseado nos indicadores selecionados
  CensoEscolarEntity? _convertCidadeToCensoEscolar(CidadeEntity? cidade) {
    if (cidade == null) return null;

    try {
      // Criar mapa de valores por etapa para lookup rápido
      final valoresPorEtapa = <String, double>{};

      // Agrupar por grupos
      final gruposMap = <int, List<CensoTitleEntity>>{};
      final grupoNomes = <int, String>{};

      for (final etapa in cidade.cidadesHasIndiceEtapa) {
        final nomeEtapa = etapa.nomeEtapa;
        final valor = etapa.etapaValor;
        final grupoId = etapa.grupoId;
        final grupoNome = etapa.indiceEtapa.grupoNome;

        // Adicionar ao mapa de valores
        valoresPorEtapa[nomeEtapa] = valor;

        // Guardar nome do grupo
        grupoNomes[grupoId] = grupoNome;

        // Criar título para este indicador
        final titulo = CensoTitleEntity(
          id: etapa.indiceEtapaId,
          nomeEtapa: nomeEtapa,
          tituloExibicao:
              etapa.indiceEtapa.nome, // Usa nome como título de exibição
          valor: valor,
          isProfessores: nomeEtapa == 'professores',
          grupoId: grupoId,
        );

        // Agrupar por grupo
        gruposMap.putIfAbsent(grupoId, () => []);
        gruposMap[grupoId]!.add(titulo);
      }

      // Converter grupos map para entidades
      final grupos = gruposMap.entries.map((entry) {
        return CensoGroupEntity(
          id: entry.key,
          nome: grupoNomes[entry.key] ?? '',
          titulos: entry.value,
        );
      }).toList();

      final censoEscolarEntity = CensoEscolarEntity(
        cidadeId: cidade.id,
        cidadeNome: cidade.nome,
        grupos: grupos,
        valoresPorEtapa: valoresPorEtapa,
      );

      print(
          '✅ [BudgetConfigStore] CensoEscolar criado: ${valoresPorEtapa.length} etapas');
      return censoEscolarEntity;
    } catch (e) {
      print('❌ [BudgetConfigStore] Erro ao converter cidade para censo: $e');
      return null;
    }
  }

  /// Verifica produtos que precisam ser remarcação após mudança no censo
  @action
  void _checkForProductsToRemark(
    CensoEscolarEntity oldCenso,
    CensoEscolarEntity newCenso,
  ) {
    final productsToRemark = <ProductEntity>[];

    // Percorrer todos os produtos para verificar mudanças
    for (final category in categories) {
      for (final subcategory in category.subcategorias) {
        for (final product in subcategory.produtos) {
          // Calcular quantidade antiga e nova
          final oldQuantity = calculationService.calcularQuantidade(
            product,
            oldCenso,
          );
          final newQuantity = calculationService.calcularQuantidade(
            product,
            newCenso,
          );

          // Se era 0 e agora > 0, adicionar à lista
          if (oldQuantity == 0 && newQuantity > 0 && !product.selecionado) {
            final updatedProduct =
                product.copyWith(quantidade: newQuantity.round());
            productsToRemark.add(updatedProduct);
          }
        }
      }
    }

    // Atualizar observable com produtos que precisam de remarcação
    productsNeedingRemark = productsToRemark;

    if (productsToRemark.isNotEmpty) {
      print(
          '🔔 [BudgetConfigStore] ${productsToRemark.length} produtos agora têm disponibilidade');
      print(
          '   📋 Produtos: ${productsToRemark.map((p) => p.solucao).join(', ')}');
    }
  }

  /// Marca os produtos como selecionados (chamado pela UI após confirmação)
  @action
  void confirmProductRemark() {
    if (productsNeedingRemark.isEmpty) return;

    print(
        '✅ [BudgetConfigStore] Confirmando remarcação de ${productsNeedingRemark.length} produtos');
    _remarkProducts(productsNeedingRemark);

    // Limpar lista após confirmação
    productsNeedingRemark = [];
  }

  /// Rejeita remarcação dos produtos (chamado pela UI)
  @action
  void rejectProductRemark() {
    if (productsNeedingRemark.isEmpty) return;

    print(
        '❌ [BudgetConfigStore] Rejeitando remarcação de ${productsNeedingRemark.length} produtos');

    // Limpar lista após rejeição
    productsNeedingRemark = [];
  }

  /// Marca os produtos como selecionados
  @action
  void _remarkProducts(List<ProductEntity> productsToRemark) {
    for (final product in productsToRemark) {
      // Encontrar e atualizar o produto na árvore
      for (var i = 0; i < categories.length; i++) {
        final category = categories[i];

        for (var j = 0; j < category.subcategorias.length; j++) {
          final subcategory = category.subcategorias[j];

          final productIndex =
              subcategory.produtos.indexWhere((p) => p.id == product.id);

          if (productIndex != -1) {
            final updatedProduct = subcategory.produtos[productIndex]
                .copyWith(selecionado: true, quantidade: product.quantidade);

            final updatedProducts =
                List<ProductEntity>.from(subcategory.produtos);
            updatedProducts[productIndex] = updatedProduct;

            final updatedSubcategory =
                subcategory.copyWith(produtos: updatedProducts);

            final updatedSubcategories =
                List<SubcategoryEntity>.from(category.subcategorias);
            updatedSubcategories[j] = updatedSubcategory;

            final updatedCategory =
                category.copyWith(subcategorias: updatedSubcategories);

            categories[i] = updatedCategory;

            print(
                '✅ [BudgetConfigStore] Produto "${product.solucao}" marcado automaticamente');
            break;
          }
        }
      }
    }
  }

  @action
  Future<void> loadBudgetDetail(int budgetId) async {
    isLoading = true;
    isLoadingProducts = true;
    error = null;

    try {
      final result = await getBudgetDetailUseCase(budgetId);

      await result.fold(
        (failure) async {
          error = failure.message;
          budgetDetail = null;
          isLoading = false;
          isLoadingProducts = false;
        },
        (budget) async {
          budgetDetail = budget;

          // ✅ Inicializar categorias COM estatísticas (sem produtos ainda)
          categories.clear();
          categories.addAll(budget.categories);

          // Inicializar estados de categorias (manter para compatibilidade)
          categoryStates.clear();
          categoryStates.addAll(budget.categoryStates);

          // Inicializar data de validade (padrão: 60 dias se não vier do backend)
          validityDate = budget.validityDate ??
              DateTime.now().add(const Duration(days: 60));

          // Inicializar nome
          budgetName = budget.name;

          // ✅ Info básica carregada
          isLoading = false;

          // 🆕 ENRICHMENT: Preencher grupos dos indicadores usando dados da cidade
          // Isso garante que os grupos apareçam mesmo se os produtos completos ainda não chegaram
          _enrichCategoriesWithCityData();

          // 🚀 EAGER LOAD: Buscar TODOS os produtos do orçamento
          await _loadAllProducts(budgetId);

          // Se o carregamento completo funcionar, ele vai sobrescrever com dados mais ricos.
          // Mas o enrichment garante a UX imediata.

          // ✅ Produtos carregados
          isLoadingProducts = false;
        },
      );
    } catch (e) {
      error = 'Erro ao carregar orçamento: $e';
      isLoading = false;
      isLoadingProducts = false;
    }
  }

  /// Carrega TODOS os produtos do orçamento de uma vez (EAGER LOAD)
  /// Distribui produtos nas categorias corretas usando subcategoriaId
  @action
  Future<void> _loadAllProducts(int budgetId) async {
    try {
      debugPrint(
          '🚀 [BudgetConfigStore] Iniciando carregamento de produtos...');

      final result = await getAllBudgetProductsUseCase(budgetId: budgetId);

      result.fold(
        (failure) {
          debugPrint(
              '❌ [BudgetConfigStore] ERRO ao carregar produtos: ${failure.message}');
          // Não definir error aqui, manter estatísticas se falhar
        },
        (allProducts) {
          debugPrint(
              '✅ [BudgetConfigStore] ${allProducts.length} produtos recebidos do UseCase');

          // Agrupar produtos por subcategoria_id
          final productsBySubcategory = <int, List<ProductEntity>>{};

          for (final product in allProducts) {
            final subId = product.subcategoriaId;
            productsBySubcategory.putIfAbsent(subId, () => []);
            productsBySubcategory[subId]!.add(product);
          }

          debugPrint('📦 [BudgetConfigStore] Produtos agrupados:');
          productsBySubcategory.forEach((subId, prods) {
            debugPrint('   - Subcategoria $subId: ${prods.length} produtos');
          });

          // Distribuir produtos nas subcategorias corretas
          final updatedCategories = categories.map((cat) {
            // Atualizar subcategorias com produtos reais
            final updatedSubcategories = cat.subcategorias.map((sub) {
              final subProducts = productsBySubcategory[sub.id] ?? [];

              if (subProducts.isEmpty) {
                debugPrint(
                    '   ⚠️ Subcategoria ${sub.id} (${sub.nome}) sem produtos - mantendo estatísticas');
                // Subcategoria sem produtos, manter como está (com estatísticas)
                return sub;
              }

              debugPrint(
                  '   ✅ Subcategoria ${sub.id} (${sub.nome}): ${subProducts.length} produtos');
              // Substituir estatísticas por produtos reais
              return sub.copyWith(
                produtos: subProducts,
                estatisticas:
                    null, // Remove estatísticas (agora tem produtos reais)
              );
            }).toList();

            return cat.copyWith(subcategorias: updatedSubcategories);
          }).toList();

          // 🔧 FIX: Forçar recriação completa do ObservableList
          // Isso garante que todos os Observers detectem a mudança
          runInAction(() {
            categories = ObservableList.of(updatedCategories);
          });

          debugPrint('🎉 [BudgetConfigStore] Merge concluído!');
          debugPrint('   Total categorias: ${categories.length}');
          debugPrint('   Total valor: R\$ ${totalValue.toStringAsFixed(2)}');
        },
      );
    } catch (e, stackTrace) {
      debugPrint('💥 [BudgetConfigStore] EXCEÇÃO ao carregar produtos: $e');
      debugPrint('Stack: $stackTrace');
      // Manter estatísticas se falhar
    }
  }

  /// Enriquece os indicadores dos produtos com informações de grupo vindas da cidade
  void _enrichCategoriesWithCityData() {
    if (budgetDetail == null || budgetDetail!.citiesData.isEmpty) return;

    try {
      // Criar mapa de indicadores da cidade para busca rápida
      // Mapa: nome_indicador -> {grupo_id, grupo_nome}
      final indicatorMap = <String, Map<String, dynamic>>{};

      // Assumindo que usamos a primeira cidade (principal) para estrutura de indicadores
      final cityData = budgetDetail!.citiesData.first;
      final indicadoresCidade = cityData['indicadores'] as List<dynamic>? ?? [];

      for (final ind in indicadoresCidade) {
        if (ind is Map<String, dynamic>) {
          final nome = ind['nome'] as String?;
          if (nome != null) {
            indicatorMap[nome] = {
              'grupo_id': ind['grupo_id'],
              'grupo_nome': ind['grupo_nome'],
            };
          }
        }
      }

      if (indicatorMap.isEmpty) return;

      // Atualizar categorias com grupos preenchidos
      final updatedCategories = categories.map((cat) {
        final updatedSubcategories = cat.subcategorias.map((sub) {
          final updatedProducts = sub.produtos.map((prod) {
            // Se produto não tem indicadores, retorna igual
            if (prod.indicadoresEtapa.isEmpty) return prod;

            // Atualizar indicadores do produto
            final updatedIndicators = prod.indicadoresEtapa.map((ind) {
              // Se já tem grupo, mantém
              if (ind.grupoNome.isNotEmpty) return ind;

              // Busca info do grupo
              final info = indicatorMap[ind.nomeEtapa] ??
                  indicatorMap[ind.indicadorNome];

              if (info != null) {
                return ind.copyWith(
                  grupoId: info['grupo_id'] as int? ?? 0,
                  grupoNome: info['grupo_nome'] as String? ?? '',
                );
              }
              return ind;
            }).toList();

            return prod.copyWith(indicadoresEtapa: updatedIndicators);
          }).toList();

          return sub.copyWith(produtos: updatedProducts);
        }).toList();

        return cat.copyWith(subcategorias: updatedSubcategories);
      }).toList();

      categories = ObservableList.of(updatedCategories);
      print(
          '✨ [BudgetConfigStore] Indicadores enriquecidos com dados da cidade: ${indicatorMap.length} tipos de indicadores');
    } catch (e) {
      print('❌ [BudgetConfigStore] Erro ao enriquecer indicadores: $e');
    }
  }

  @action
  Future<void> loadCensusData(int cityId) async {
    isLoadingCensus = true;

    try {
      final result = await getCensusDataUseCase(cityId);

      result.fold(
        (failure) {
          // Não definir error aqui pois censo é opcional
          censusData = null;
        },
        (census) {
          censusData = census;
        },
      );
    } catch (e) {
      censusData = null;
    } finally {
      isLoadingCensus = false;
    }
  }

  @action
  void toggleCategory(String categoryKey) {
    final newValue = toggleCategoryUseCase(categoryKey, categoryStates);
    categoryStates[categoryKey] = newValue;
  }

  @action
  void setValidityDate(DateTime? date) {
    validityDate = date;
  }

  @action
  void setBudgetName(String? name) {
    budgetName = name;
  }

  @action
  Future<Either<BudgetFailure, BudgetDetailEntity>> finalizeBudget() async {
    if (budgetDetail == null) {
      error = 'Orçamento não carregado';
      return const Left(ValidationFailure('Orçamento não carregado'));
    }

    isSaving = true;
    error = null;

    try {
      print('🔄 [BudgetConfigStore] Finalizando orçamento...');

      final result = await finalizeBudgetUseCase(
        budgetId: budgetDetail!.id,
        categoryStates: categoryStates,
        validityDate: validityDate,
        name: budgetName,
      );

      return result.fold(
        (failure) {
          print('❌ [BudgetConfigStore] Erro ao finalizar: ${failure.message}');
          error = failure.message;
          isSaving = false;
          return Left(failure);
        },
        (updatedBudget) {
          print('✅ [BudgetConfigStore] Orçamento finalizado com sucesso');
          budgetDetail = updatedBudget;
          isSaving = false;
          return Right(updatedBudget);
        },
      );
    } catch (e) {
      print('❌ [BudgetConfigStore] Erro inesperado: $e');
      error = 'Erro ao finalizar orçamento: $e';
      isSaving = false;
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ========== NOVOS ACTIONS PARA CATEGORIAS E PRODUTOS ==========

  @action
  void selectCategory(CategoryEntity? category) {
    selectedCategory = category;
    print('📂 [BudgetConfigStore] Categoria selecionada: ${category?.nome}');
  }

  @action
  void selectSubcategory(SubcategoryEntity? subcategory) {
    selectedSubcategory = subcategory;
    print(
        '📁 [BudgetConfigStore] Subcategoria selecionada: ${subcategory?.nome}');
  }

  @action
  void toggleProduct(int productId, bool selected) {
    print(
        '🔄 [BudgetConfigStore] Alternando produto: $productId para $selected');

    // Encontrar o produto em todas as categorias/subcategorias
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];

        final productIndex =
            subcategory.produtos.indexWhere((p) => p.id == productId);

        if (productIndex != -1) {
          final product = subcategory.produtos[productIndex];

          // ⚠️ Só permitir alteração se o produto estiver ativo
          if (!product.ativo) {
            return;
          }

          // ✅ Alternar campo 'selecionado'
          final updatedProduct = product.copyWith(selecionado: selected);

          // 🧮 Recalcular quantidade e valor baseado no censo
          if (censoEscolar != null && selected) {
            final quantidade = calculationService.calcularQuantidade(
              updatedProduct,
              censoEscolar!,
            );
            final valorTotal = calculationService.calcularValorProduto(
              updatedProduct,
              censoEscolar!,
            );

            // Atualizar produto com valores calculados
            final productWithCalculation = updatedProduct.copyWith(
              quantidade: quantidade.round(),
              valor: valorTotal > 0
                  ? valorTotal / quantidade
                  : updatedProduct.valor,
            );

            // Atualizar na subcategoria
            final updatedProducts =
                subcategory.produtos.asMap().entries.map((entry) {
              return entry.key == productIndex
                  ? productWithCalculation
                  : entry.value;
            }).toList();

            final updatedSubcategory =
                subcategory.copyWith(produtos: updatedProducts);
            final updatedSubcategories =
                category.subcategorias.asMap().entries.map((entry) {
              return entry.key == j ? updatedSubcategory : entry.value;
            }).toList();

            categories[i] =
                category.copyWith(subcategorias: updatedSubcategories);
          } else {
            // Criar nova lista de produtos com imutabilidade
            final updatedProducts =
                subcategory.produtos.asMap().entries.map((entry) {
              return entry.key == productIndex ? updatedProduct : entry.value;
            }).toList();

            final updatedSubcategory =
                subcategory.copyWith(produtos: updatedProducts);
            final updatedSubcategories =
                category.subcategorias.asMap().entries.map((entry) {
              return entry.key == j ? updatedSubcategory : entry.value;
            }).toList();

            categories[i] =
                category.copyWith(subcategorias: updatedSubcategories);
          }

          print(
              '✅ [BudgetConfigStore] Produto $productId atualizado com sucesso');
          return;
        }
      }
    }

    print('⚠️ [BudgetConfigStore] Produto $productId não encontrado');
  }

  @action
  void toggleSubcategoryWithCascade(
      int categoryId, int subcategoryId, bool selected) {
    print(
        '🔄 [BudgetConfigStore] Alternando subcategoria $subcategoryId: $selected');

    // Encontrar a categoria
    final categoryIndex = categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex == -1) return;

    final category = categories[categoryIndex];

    // Encontrar a subcategoria
    final subcategoryIndex =
        category.subcategorias.indexWhere((s) => s.id == subcategoryId);
    if (subcategoryIndex == -1) return;

    final subcategory = category.subcategorias[subcategoryIndex];

    // Alternar todos os produtos da subcategoria
    final updatedProducts = subcategory.produtos.map((product) {
      if (!product.ativo) return product;
      return product.copyWith(selecionado: selected);
    }).toList();

    // Atualizar subcategoria
    final updatedSubcategory = subcategory.copyWith(produtos: updatedProducts);
    final updatedSubcategories =
        category.subcategorias.asMap().entries.map((entry) {
      return entry.key == subcategoryIndex ? updatedSubcategory : entry.value;
    }).toList();

    categories[categoryIndex] =
        category.copyWith(subcategorias: updatedSubcategories);
  }

  @action
  void toggleCategoryWithCascade(int categoryId, bool selected) {
    print('🔄 [BudgetConfigStore] Alternando categoria $categoryId: $selected');

    // Encontrar a categoria
    final categoryIndex = categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex == -1) return;

    final category = categories[categoryIndex];

    // Alternar todos os produtos de todas as subcategorias
    final updatedSubcategories = category.subcategorias.map((subcategory) {
      final updatedProducts = subcategory.produtos.map((product) {
        if (!product.ativo) return product;
        return product.copyWith(selecionado: selected);
      }).toList();
      return subcategory.copyWith(produtos: updatedProducts);
    }).toList();

    categories[categoryIndex] =
        category.copyWith(subcategorias: updatedSubcategories);
  }

  @action
  void updateProductFromModal(ProductEntity updatedProduct) {
    print(
        '🔄 [BudgetConfigStore] Atualizando produto do modal: ${updatedProduct.id}');

    // Encontrar o produto em todas as categorias/subcategorias
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];

        final productIndex =
            subcategory.produtos.indexWhere((p) => p.id == updatedProduct.id);

        if (productIndex != -1) {
          // Atualizar produto completo
          final updatedProducts =
              subcategory.produtos.asMap().entries.map((entry) {
            return entry.key == productIndex ? updatedProduct : entry.value;
          }).toList();

          final updatedSubcategory =
              subcategory.copyWith(produtos: updatedProducts);
          final updatedSubcategories =
              category.subcategorias.asMap().entries.map((entry) {
            return entry.key == j ? updatedSubcategory : entry.value;
          }).toList();

          categories[i] =
              category.copyWith(subcategorias: updatedSubcategories);

          print(
              '✅ [BudgetConfigStore] Produto ${updatedProduct.id} atualizado com sucesso');
          return;
        }
      }
    }

    print('⚠️ [BudgetConfigStore] Produto ${updatedProduct.id} não encontrado');
  }

  @action
  void updateProductQuantity(int productId, int quantity) {
    print(
        '🔄 [BudgetConfigStore] Atualizando quantidade do produto: $productId para $quantity');

    if (quantity < 1) {
      print('⚠️ [BudgetConfigStore] Quantidade inválida: $quantity');
      return;
    }

    // Encontrar o produto
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];

        final productIndex =
            subcategory.produtos.indexWhere((p) => p.id == productId);

        if (productIndex != -1) {
          final product = subcategory.produtos[productIndex];

          // ⚠️ Só permitir se estiver ativo
          if (!product.ativo) {
            print('⚠️ [BudgetConfigStore] Produto $productId está inativo');
            return;
          }

          // Atualizar quantidade
          final updatedProduct = product.copyWith(quantidade: quantity);

          // Criar nova lista de produtos
          final updatedProducts =
              List<ProductEntity>.from(subcategory.produtos);
          updatedProducts[productIndex] = updatedProduct;

          // Criar nova subcategoria
          final updatedSubcategory =
              subcategory.copyWith(produtos: updatedProducts);

          // Criar nova lista de subcategorias
          final updatedSubcategories =
              List<SubcategoryEntity>.from(category.subcategorias);
          updatedSubcategories[j] = updatedSubcategory;

          // Criar nova categoria
          final updatedCategory =
              category.copyWith(subcategorias: updatedSubcategories);

          // Atualizar a categoria na lista
          categories[i] = updatedCategory;

          print('✅ [BudgetConfigStore] Quantidade atualizada');
          print('💰 Total recalculado: R\$ ${totalValue.toStringAsFixed(2)}');
          return;
        }
      }
    }

    print('⚠️ [BudgetConfigStore] Produto $productId não encontrado');
  }

  @action
  void updateProductValue(int productId, double value) {
    print(
        '🔄 [BudgetConfigStore] Atualizando valor do produto: $productId para $value');

    // Encontrar o produto em todas as categorias/subcategorias
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];

        final productIndex =
            subcategory.produtos.indexWhere((p) => p.id == productId);

        if (productIndex != -1) {
          final product = subcategory.produtos[productIndex];

          // ⚠️ Só permitir se estiver ativo
          if (!product.ativo) {
            print('⚠️ [BudgetConfigStore] Produto $productId está inativo');
            return;
          }

          // Atualizar valor
          final updatedProduct = product.copyWith(valor: value);

          // Criar nova lista de produtos
          final updatedProducts =
              List<ProductEntity>.from(subcategory.produtos);
          updatedProducts[productIndex] = updatedProduct;

          // Criar nova subcategoria
          final updatedSubcategory =
              subcategory.copyWith(produtos: updatedProducts);

          // Criar nova lista de subcategorias
          final updatedSubcategories =
              List<SubcategoryEntity>.from(category.subcategorias);
          updatedSubcategories[j] = updatedSubcategory;

          // Criar nova categoria
          final updatedCategory =
              category.copyWith(subcategorias: updatedSubcategories);

          // Atualizar a categoria na lista
          categories[i] = updatedCategory;

          print('✅ [BudgetConfigStore] Valor atualizado');
          print('💰 Total recalculado: R\$ ${totalValue.toStringAsFixed(2)}');
          return;
        }
      }
    }

    print('⚠️ [BudgetConfigStore] Produto $productId não encontrado');
  }

  @action
  void updateProductObservations(int productId, String? observations) {
    print(
        '🔄 [BudgetConfigStore] Atualizando observações do produto: $productId');

    // Encontrar o produto
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];

        final productIndex =
            subcategory.produtos.indexWhere((p) => p.id == productId);

        if (productIndex != -1) {
          final product = subcategory.produtos[productIndex];

          // Atualizar observações
          final updatedProduct = product.copyWith(observacoes: observations);

          // Criar nova lista de produtos
          final updatedProducts =
              List<ProductEntity>.from(subcategory.produtos);
          updatedProducts[productIndex] = updatedProduct;

          // Criar nova subcategoria
          final updatedSubcategory =
              subcategory.copyWith(produtos: updatedProducts);

          // Criar nova lista de subcategorias
          final updatedSubcategories =
              List<SubcategoryEntity>.from(category.subcategorias);
          updatedSubcategories[j] = updatedSubcategory;

          // Criar nova categoria
          final updatedCategory =
              category.copyWith(subcategorias: updatedSubcategories);

          // Atualizar a categoria na lista
          categories[i] = updatedCategory;

          print('✅ [BudgetConfigStore] Observações atualizadas');
          return;
        }
      }
    }

    print('⚠️ [BudgetConfigStore] Produto $productId não encontrado');
  }

  @action
  void toggleProductIndicator(int productId, int indicatorId) {
    print(
        '🔄 [BudgetConfigStore] Alternando indicador $indicatorId do produto $productId');

    // Encontrar o produto
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];

        final productIndex =
            subcategory.produtos.indexWhere((p) => p.id == productId);

        if (productIndex != -1) {
          final product = subcategory.produtos[productIndex];

          // Encontrar o indicador na lista do produto
          final indicatorIndex = product.indicadoresEtapa
              .indexWhere((ind) => ind.produtoIndicadorId == indicatorId);

          if (indicatorIndex != -1) {
            final indicator = product.indicadoresEtapa[indicatorIndex];
            final newSelectedState = !indicator.selecionado;

            // Atualizar o indicador
            final updatedIndicator =
                indicator.copyWith(selecionado: newSelectedState);

            // Atualizar lista de indicadores
            final updatedIndicators =
                List<IndicadorEtapaEntity>.from(product.indicadoresEtapa);
            updatedIndicators[indicatorIndex] = updatedIndicator;

            // Atualizar produto com novos indicadores
            var updatedProduct =
                product.copyWith(indicadoresEtapa: updatedIndicators);

            // 🧮 RECALCULAR quantidade baseado nos indicadores selecionados
            if (censoEscolar != null) {
              final novaQuantidade = calculationService.calcularQuantidade(
                updatedProduct,
                censoEscolar!,
              );

              // Atualiza o produto com a quantidade recalculada
              updatedProduct = updatedProduct.copyWith(
                quantidade: novaQuantidade.round(),
              );

              print(
                  '🧮 [BudgetConfigStore] Recálculo: Qtd ${product.quantidade} -> ${updatedProduct.quantidade}');
            } else {
              print(
                  '⚠️ [BudgetConfigStore] censoEscolar é null, quantidade não recalculada');
            }

            // Propagar atualização na árvore
            final updatedProducts =
                List<ProductEntity>.from(subcategory.produtos);
            updatedProducts[productIndex] = updatedProduct;

            final updatedSubcategory =
                subcategory.copyWith(produtos: updatedProducts);

            final updatedSubcategories =
                List<SubcategoryEntity>.from(category.subcategorias);
            updatedSubcategories[j] = updatedSubcategory;

            final updatedCategory =
                category.copyWith(subcategorias: updatedSubcategories);

            categories[i] = updatedCategory;

            print(
                '✅ [BudgetConfigStore] Indicador atualizado para $newSelectedState');
            return;
          }
        }
      }
    }
    print('⚠️ [BudgetConfigStore] Indicador não encontrado');
  }

  @action
  void updateProductIndicators(
      int productId, Map<String, List<String>> selectedIndicators) {
    print(
        '🔄 [BudgetConfigStore] Atualizando indicadores do produto: $productId');
    print('   📋 Indicadores selecionados: $selectedIndicators');

    // Encontrar o produto
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];

        final productIndex =
            subcategory.produtos.indexWhere((p) => p.id == productId);

        if (productIndex != -1) {
          final product = subcategory.produtos[productIndex];

          // ⚠️ Só permitir se estiver ativo
          if (!product.ativo) {
            print('⚠️ [BudgetConfigStore] Produto $productId está inativo');
            return;
          }

          // Atualizar indicadores
          // TODO: Adicionar campo para armazenar indicadores selecionados no ProductEntity
          // Por enquanto, apenas loga a ação
          print('✅ [BudgetConfigStore] Indicadores atualizados com sucesso');
          print(
              '   📊 Total de grupos selecionados: ${selectedIndicators.length}');

          // Criar nova lista de produtos (por enquanto, sem alteração)
          // No futuro, adicionar campo selectedIndicators ao ProductEntity
          final updatedProducts =
              List<ProductEntity>.from(subcategory.produtos);

          // Criar nova subcategoria
          final updatedSubcategory =
              subcategory.copyWith(produtos: updatedProducts);

          // Criar nova lista de subcategorias
          final updatedSubcategories =
              List<SubcategoryEntity>.from(category.subcategorias);
          updatedSubcategories[j] = updatedSubcategory;

          // Criar nova categoria
          final updatedCategory =
              category.copyWith(subcategorias: updatedSubcategories);

          // Atualizar a categoria na lista
          categories[i] = updatedCategory;

          return;
        }
      }
    }

    print('⚠️ [BudgetConfigStore] Produto $productId não encontrado');
  }

  /// Atualiza categoria com produtos carregados e marca/desmarca todos
  void _updateCategoryWithProducts(
    int categoryId,
    List<ProductEntity> products, {
    required bool selected,
  }) {
    final categoryIndex = categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex == -1) return;

    final category = categories[categoryIndex];

    print(
        '   📦 Distribuindo ${products.length} produtos nas subcategorias da categoria ${category.nome}');

    // Backend retorna produtos com subcategoria_id
    // Vamos agrupar produtos por subcategoriaId
    print('   🔍 Agrupando produtos por subcategoriaId...');
    final productsBySubcategory = <int, List<ProductEntity>>{};

    for (final product in products) {
      final subId = product.subcategoriaId;
      productsBySubcategory.putIfAbsent(subId, () => []).add(product);
      print('      - Produto ${product.codigo} → Subcategoria ID: $subId');
    }

    print('   🔍 Subcategorias com produtos:');
    productsBySubcategory.forEach((subId, prods) {
      print('      - Subcategoria ID $subId: ${prods.length} produtos');
    });

    print('   🔍 Subcategorias existentes na categoria:');
    for (final sub in category.subcategorias) {
      print('      - ${sub.nome} (ID: ${sub.id})');
    }

    // Atualizar cada subcategoria com seus produtos específicos
    final updatedSubcategories = category.subcategorias.map((sub) {
      // Buscar produtos desta subcategoria
      final subcategoryProducts = productsBySubcategory[sub.id] ?? [];

      // Marcar/desmarcar todos os produtos
      final updatedProducts = subcategoryProducts
          .map((p) => p.copyWith(
                selecionado: selected,
                quantidade: selected ? 1 : 1,
              ))
          .toList();

      print(
          '      ✓ Subcategoria ${sub.nome} (ID: ${sub.id}): ${updatedProducts.length} produtos');

      // Remover estatísticas (agora tem produtos reais)
      return sub.copyWith(
        produtos: updatedProducts,
        estatisticas: null,
      );
    }).toList();

    // Atualizar categoria
    final updatedCategory =
        category.copyWith(subcategorias: updatedSubcategories);

    // Atualizar lista
    final newCategories = List<CategoryEntity>.from(categories);
    newCategories[categoryIndex] = updatedCategory;
    categories = ObservableList.of(newCategories);

    print('   ✅ Categoria atualizada com produtos reais');
  }

  /// Marca/desmarca todos os produtos de uma categoria (quando produtos já estão carregados)
  void _selectAllProductsInCategory(int categoryId, {required bool selected}) {
    final categoryIndex = categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex == -1) return;

    final category = categories[categoryIndex];

    final updatedSubcategories = category.subcategorias.map((sub) {
      final updatedProducts = sub.produtos
          .map((p) => p.copyWith(
                selecionado: selected,
                quantidade: selected ? 1 : 1,
              ))
          .toList();

      return sub.copyWith(produtos: updatedProducts);
    }).toList();

    final updatedCategory =
        category.copyWith(subcategorias: updatedSubcategories);

    final newCategories = List<CategoryEntity>.from(categories);
    newCategories[categoryIndex] = updatedCategory;
    categories = ObservableList.of(newCategories);
  }

  /// 🔄 Recarrega produtos quando censo escolar é editado
  /// Backend recalcula as quantidades baseado nos novos dados do censo
  @action
  Future<void> reloadProductsAfterCensusEdit() async {
    if (budgetDetail == null) return;

    print(
        '🔄 [BudgetConfigStore] Recarregando produtos após edição do censo...');

    isLoadingProducts = true;
    error = null;

    try {
      await _loadAllProducts(budgetDetail!.id);
      print(
          '✅ [BudgetConfigStore] Produtos recarregados com novas quantidades');
    } catch (e) {
      error = 'Erro ao recarregar produtos: $e';
      print('❌ [BudgetConfigStore] Erro ao recarregar: $e');
    } finally {
      isLoadingProducts = false;
    }
  }

  @action
  void reset() {
    budgetDetail = null;
    censusData = null;
    categories.clear();
    categoryStates.clear();
    selectedCategory = null;
    selectedSubcategory = null;
    validityDate = null;
    budgetName = null;
    error = null;
    isLoading = false;
    isLoadingCensus = false;
    isSaving = false;
  }

  /// 💾 Salva orçamento configurado como "pendente"
  ///
  /// Utilizado quando o usuário:
  /// 1. Cria um orçamento (rascunho)
  /// 2. Configura produtos e quantidades
  /// 3. Clica em "Salvar Orçamento"
  ///
  /// Este método coleta todos os produtos e suas quantidades,
  /// calcula o total e atualiza o status para "pendente"
  @action
  Future<Either<BudgetFailure, BudgetDetailEntity>> saveBudget() async {
    if (budgetDetail == null) {
      error = 'Orçamento não carregado';
      return const Left(ValidationFailure('Orçamento não carregado'));
    }

    if (validityDate == null) {
      error = 'Data de validade não definida';
      return const Left(ValidationFailure('Data de validade obrigatória'));
    }

    isSaving = true;
    error = null;

    try {
      print('💾 [BudgetConfigStore] Salvando orçamento como PENDENTE...');

      // 1. Coletar todos os produtos de todas as categorias/subcategorias
      final produtosParaSalvar = <ProductSelectionUpdateDto>[];

      for (final category in categories) {
        for (final subcategory in category.subcategorias) {
          for (final product in subcategory.produtos) {
            produtosParaSalvar.add(ProductSelectionUpdateDto(
              productId: product.id,
              selecionado: product.selecionado,
              quantidade: product.quantidade,
            ));
          }
        }
      }

      print('   📦 Salvando ${produtosParaSalvar.length} produtos');
      print(
          '   ✅ Selecionados: ${produtosParaSalvar.where((p) => p.selecionado).length}');

      // 2. Calcular total
      final totalCalculado = totalValue;

      // 3. Calcular dias de validade
      final diasValidade = validityDate!.difference(DateTime.now()).inDays;

      // 4. Criar DTO de atualização
      final updateDto = BudgetUpdateDto(
        nome: budgetName,
        diasValidade: diasValidade > 0 ? diasValidade : 1,
        status: 'pendente', // ⚠️ SEMPRE pendente no budget_config
        total: totalCalculado,
        produtos: produtosParaSalvar,
      );

      // 5. Chamar UseCase
      final result = await saveBudgetUseCase(
        budgetId: budgetDetail!.id,
        updateData: updateDto,
      );

      return result.fold(
        (failure) {
          print('❌ [BudgetConfigStore] Erro ao salvar: ${failure.message}');
          error = failure.message;
          isSaving = false;
          return Left(failure);
        },
        (updatedBudget) {
          print('✅ [BudgetConfigStore] Orçamento salvo com status PENDENTE');
          budgetDetail = updatedBudget;
          isSaving = false;
          return Right(updatedBudget);
        },
      );
    } catch (e) {
      print('❌ [BudgetConfigStore] Erro inesperado: $e');
      error = 'Erro ao salvar orçamento: $e';
      isSaving = false;
      return Left(UnknownFailure(e.toString()));
    }
  }
}
