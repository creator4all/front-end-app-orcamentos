import 'package:dartz/dartz.dart';
import 'package:mobx/mobx.dart';

import '../../../../../../shared/utils/api_number_parser.dart';
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
import '../../domain/services/budget_value_rules.dart';
import '../../domain/services/censo_escolar_mapper.dart';
import '../../domain/services/product_calculation_service.dart';
import '../../domain/services/product_quantity_rules.dart';
import '../../domain/usecases/calculate_totals_usecase.dart';
import '../../domain/usecases/get_budget_detail_usecase.dart';
import '../../domain/usecases/get_category_products_usecase.dart';
import '../../domain/usecases/get_census_data_usecase.dart';
import '../../domain/usecases/save_budget_usecase.dart';
import '../../domain/usecases/toggle_category_usecase.dart';

part 'budget_config_store.g.dart';

class BudgetConfigStore = _BudgetConfigStoreBase with _$BudgetConfigStore;

abstract class _BudgetConfigStoreBase with Store {
  final GetBudgetDetailUseCase getBudgetDetailUseCase;
  final GetCategoryProductsUseCase getCategoryProductsUseCase;
  final GetCensusDataUseCase getCensusDataUseCase;
  final ToggleCategoryUseCase toggleCategoryUseCase;
  final CalculateTotalsUseCase calculateTotalsUseCase;
  final SaveBudgetUseCase saveBudgetUseCase;
  final ProductCalculationService calculationService;
  final CensoEscolarMapper censoEscolarMapper;

  _BudgetConfigStoreBase({
    required this.getBudgetDetailUseCase,
    required this.getCategoryProductsUseCase,
    required this.getCensusDataUseCase,
    required this.toggleCategoryUseCase,
    required this.calculateTotalsUseCase,
    required this.saveBudgetUseCase,
    required this.calculationService,
    required this.censoEscolarMapper,
  });

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

  /// Valor original de dias_validade recebido do backend
  int? _originalValidityDays;

  /// Indica se o usuário alterou a data de validade nesta sessão
  bool _validityDateChanged = false;

  // ── Snapshot do estado inicial dos produtos (para delta no PUT) ──
  final Map<int, bool> _origSelecionado = {};
  final Map<int, double> _origQuantidade = {};
  final Map<int, bool> _origQuantidadeManual = {};
  final Map<int, double> _origValor = {};
  final Map<int, Map<int, bool>> _origIndicadores = {};

  /// Indica se o snapshot inicial dos produtos já foi capturado nesta sessão.
  bool _snapshotTaken = false;

  @observable
  String? budgetName;

  @observable
  ObservableList<CategoryEntity> categories = ObservableList<CategoryEntity>();

  @observable
  CategoryEntity? selectedCategory;

  @observable
  SubcategoryEntity? selectedSubcategory;

  @observable
  List<ProductEntity> productsNeedingRemark = [];

  @computed
  bool get canFinalize {
    if (budgetDetail == null) return false;
    if (validityDate == null) return false;

    return totalSelectedProducts > 0;
  }

  @computed
  int get selectedCategoriesCount {
    return categories.where((c) => c.hasSelectedProducts).length;
  }

  @computed
  double get totalValue {
    return categories.fold(0.0, (sum, c) => sum + c.totalValue);
  }

  @computed
  int get selectedProductsCount {
    return categories.fold(0, (sum, c) => sum + c.selectedProductsCount);
  }

  @computed
  int get totalActiveProducts {
    return categories.fold(0, (sum, c) => sum + c.totalActiveProducts);
  }

  @computed
  int get totalSelectedProducts {
    return categories.fold(0, (sum, c) => sum + c.selectedProductsCount);
  }

  @computed
  int get selectedItemsCount {
    return categories.fold(0, (sum, category) {
      if (category.expandido) {
        final selectedSubcategories = category.subcategorias
            .where((subcategory) => subcategory.hasSelectedProducts)
            .length;
        return sum + selectedSubcategories;
      } else {
        return sum + (category.hasSelectedProducts ? 1 : 0);
      }
    });
  }

  @computed
  bool get hasData => budgetDetail != null;

  @computed
  bool get hasCensusData => censusData != null && censusData!.hasData;

  @computed
  bool get hasCategories => categories.isNotEmpty;

  @computed
  bool get isFullyLoaded => !isLoading && !isLoadingProducts;

  @action
  Future<void> initialize(int budgetId) async {
    await loadBudgetDetail(budgetId);

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
        name: draft.name,
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
      budgetName = draft.name ?? '';
      _originalValidityDays = draft.validityDays;
      _validityDateChanged = false;

      final oldCensoEscolar = censoEscolar;
      censoEscolar = _convertCidadeToCensoEscolar(draft.cidade);

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

      if (censoEscolar != null) {
        final updated = calculationService.recalcularQuantidadesProdutos(
          categories.toList(),
          censoEscolar!,
        );
        for (var i = 0; i < updated.length; i++) {
          categories[i] = updated[i];
        }
      }
    } catch (e) {
      error = 'Erro ao inicializar orçamento: $e';
      isLoading = false;
    }
  }

  List<Map<String, dynamic>> _extractCitiesDataFromDraft(
      BudgetDraftEntity draft) {
    if (draft.cidade == null) return [];

    final cidade = draft.cidade!;
    final indices = cidade.cidadesHasIndiceEtapa.map((etapa) {
      final grupoNome = etapa.indiceEtapa.grupoNome;
      return <String, dynamic>{
        'id': etapa.indiceEtapaId,
        'nome_etapa': etapa.nomeEtapa,
        'titulo': etapa.tituloEtapa.isNotEmpty
            ? etapa.tituloEtapa
            : etapa.indiceEtapa.titulo,
        'valor': etapa.etapaValor,
        'grupo': {
          'id': etapa.grupoId,
          'nome': grupoNome,
        },
      };
    }).toList();

    return [
      {
        'id': cidade.id,
        'nome': cidade.nome,
        'indices': indices,
        'indicadores': indices
            .map((item) => <String, dynamic>{
                  'id': item['id'],
                  'nome': item['nome_etapa'],
                  'titulo': item['titulo'],
                  'valor': item['valor'],
                  'grupo_id': (item['grupo'] as Map<String, dynamic>)['id'],
                  'grupo_nome': (item['grupo'] as Map<String, dynamic>)['nome'],
                })
            .toList(),
      }
    ];
  }

  ProductEntity _synchronizeProductSelection(ProductEntity product) {
    final shouldBeSelected = product.quantidade > 0;

    if (product.selecionado != shouldBeSelected) {
      return product.copyWith(selecionado: shouldBeSelected);
    }

    return product;
  }

  CensoEscolarEntity? _convertCidadeToCensoEscolar(CidadeEntity? cidade) {
    if (cidade == null) return null;

    try {
      final valoresPorEtapa = <String, double>{};
      final gruposMap = <int, List<CensoTitleEntity>>{};
      final grupoNomes = <int, String>{};

      for (final etapa in cidade.cidadesHasIndiceEtapa) {
        final nomeEtapa = etapa.nomeEtapa;
        final valor = etapa.etapaValor;
        final grupoId = etapa.grupoId;
        final grupoNome = etapa.indiceEtapa.grupoNome;

        valoresPorEtapa[nomeEtapa] = valor;

        grupoNomes[grupoId] = grupoNome;

        final titulo = CensoTitleEntity(
          id: etapa.indiceEtapaId,
          nomeEtapa: nomeEtapa,
          tituloExibicao: etapa.indiceEtapa.titulo,
          valor: valor,
          isProfessores: nomeEtapa.endsWith('P'),
          grupoId: grupoId,
          percentualPopulacao: etapa.indiceEtapa.percentualPopulacao,
        );

        gruposMap.putIfAbsent(grupoId, () => []);
        gruposMap[grupoId]!.add(titulo);
      }

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
        anoPopulacao: cidade.anoPopulacao,
        grupos: grupos,
        valoresPorEtapa: valoresPorEtapa,
      );

      return censoEscolarEntity;
    } catch (e) {
      return null;
    }
  }

  @action
  void _checkForProductsToRemark(
    CensoEscolarEntity oldCenso,
    CensoEscolarEntity newCenso,
  ) {
    final productsToRemark = <ProductEntity>[];

    for (final category in categories) {
      for (final subcategory in category.subcategorias) {
        for (final product in subcategory.produtos) {
          final oldQuantity = calculationService.calcularQuantidade(
            product,
            oldCenso,
          );
          final newQuantity = calculationService.calcularQuantidade(
            product,
            newCenso,
          );

          if (oldQuantity == 0 && newQuantity > 0 && !product.selecionado) {
            final updatedProduct = product.copyWith(quantidade: newQuantity);
            productsToRemark.add(updatedProduct);
          }
        }
      }
    }

    productsNeedingRemark = productsToRemark;
  }

  @action
  void confirmProductRemark() {
    _ensureSnapshot();
    if (productsNeedingRemark.isEmpty) return;

    _remarkProducts(productsNeedingRemark);

    productsNeedingRemark = [];
  }

  @action
  void rejectProductRemark() {
    if (productsNeedingRemark.isEmpty) return;

    productsNeedingRemark = [];
  }

  @action
  void updateCensoEscolar(CensoEscolarEntity updatedCenso) {
    _ensureSnapshot();
    censoEscolar = updatedCenso;

    if (budgetDetail != null) {
      final currentCities = budgetDetail!.citiesData;
      final updatedCities = <Map<String, dynamic>>[];
      var cityUpdated = false;

      for (final cityData in currentCities) {
        final cityId =
            ApiNumberParser.toInt(cityData['id'] ?? cityData['idCidades']);
        if (cityId == updatedCenso.cidadeId && updatedCenso.cidadeId > 0) {
          updatedCities.add(censoEscolarMapper.updateCityDataWithCenso(
              cityData, updatedCenso));
          cityUpdated = true;
        } else {
          updatedCities.add(cityData);
        }
      }

      if (!cityUpdated && updatedCenso.cidadeId > 0) {
        updatedCities.add(
          censoEscolarMapper
              .updateCityDataWithCenso(<String, dynamic>{}, updatedCenso),
        );
      }

      final updatedCensoAgregado =
          censoEscolarMapper.calculateAggregatedCensoFromCities(
        updatedCities,
        budgetDetail!.censoAgregado,
      );

      budgetDetail = budgetDetail!.copyWith(
        citiesData: updatedCities,
        censoAgregado: updatedCensoAgregado,
      );

      // Em multi-cidade a tela de censo devolve só a cidade editada; o
      // orçamento continua calculando com o censo agregado de todas as cidades.
      if (budgetDetail!.isMultiCity) {
        censoEscolar = censoEscolarMapper.buildAggregatedCenso(
          censoAgregado: updatedCensoAgregado,
          citiesData: updatedCities,
        );
      }
    }
  }

  @action
  void _remarkProducts(List<ProductEntity> productsToRemark) {
    for (final product in productsToRemark) {
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

          categories.clear();
          categories.addAll(budget.categories);

          categoryStates.clear();
          categoryStates.addAll(budget.categoryStates);

          validityDate = budget.validityDate ??
              DateTime.now().add(const Duration(days: 60));

          budgetName = budget.name;
          _originalValidityDays = budget.validityDays;
          _validityDateChanged = false;

          // A visão agregada só substitui a cidade quando há mais de uma:
          // um orçamento de cidade única também recebe `censo_agregado`, e
          // agregá-lo apagaria nome, ID e ano de população da cidade.
          if (budget.isMultiCity && budget.censoAgregado.isNotEmpty) {
            censoEscolar = censoEscolarMapper.buildAggregatedCenso(
              censoAgregado: budget.censoAgregado,
              citiesData: budget.citiesData,
            );
          } else if (budget.citiesData.isNotEmpty) {
            censoEscolar = censoEscolarMapper
                .buildCensoFromCityData(budget.citiesData.first);
          } else {
            censoEscolar = null;
          }

          // Regra de negócio: recalcula quantidades (ceil in4ano/in5ano)
          if (censoEscolar != null) {
            final updated = calculationService.recalcularQuantidadesProdutos(
              categories.toList(),
              censoEscolar!,
            );
            for (var i = 0; i < updated.length; i++) {
              categories[i] = updated[i];
            }
          }

          isLoading = false;

          isLoadingProducts = false;
        },
      );
    } catch (e) {
      error = 'Erro ao carregar orçamento: $e';
      isLoading = false;
      isLoadingProducts = false;
    }
  }

  void _enrichCategoriesWithCityData() {
    if (budgetDetail == null || budgetDetail!.citiesData.isEmpty) return;

    try {
      final indicatorMap = <String, Map<String, dynamic>>{};

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

      final updatedCategories = categories.map((cat) {
        final updatedSubcategories = cat.subcategorias.map((sub) {
          final updatedProducts = sub.produtos.map((prod) {
            if (prod.indicadoresEtapa.isEmpty) return prod;

            final updatedIndicators = prod.indicadoresEtapa.map((ind) {
              if (ind.grupoNome.isNotEmpty) return ind;

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
    } catch (e) {}
  }

  @action
  Future<void> loadCensusData(int cityId) async {
    isLoadingCensus = true;

    try {
      final result = await getCensusDataUseCase(cityId);

      result.fold(
        (failure) {
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
    _validityDateChanged = true;
  }

  @action
  void setBudgetName(String? name) {
    budgetName = name;
  }

  @action
  void selectCategory(CategoryEntity? category) {
    selectedCategory = category;
  }

  @action
  void selectSubcategory(SubcategoryEntity? subcategory) {
    selectedSubcategory = subcategory;
  }

  @action
  void toggleProduct(int productId, bool selected) {
    _ensureSnapshot();
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];

        final productIndex =
            subcategory.produtos.indexWhere((p) => p.id == productId);

        if (productIndex != -1) {
          final product = subcategory.produtos[productIndex];

          final updatedProduct = product.copyWith(selecionado: selected);

          if (censoEscolar != null && selected) {
            final todosProdutos = categories
                .expand((c) => c.subcategorias.expand((s) => s.produtos))
                .toList();
            final quantidade = calculationService.calcularQuantidade(
              updatedProduct,
              censoEscolar!,
              todosProdutos: todosProdutos,
            );

            final productWithCalculation = updatedProduct.copyWith(
              quantidade: quantidade,
            );

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

          _recalcServicosDependentes({productId});
          return;
        }
      }
    }
  }

  @action
  void toggleSubcategoryWithCascade(
      int categoryId, int subcategoryId, bool selected) {
    _ensureSnapshot();
    final categoryIndex = categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex == -1) return;

    final category = categories[categoryIndex];

    final subcategoryIndex =
        category.subcategorias.indexWhere((s) => s.id == subcategoryId);
    if (subcategoryIndex == -1) return;

    final subcategory = category.subcategorias[subcategoryIndex];

    final updatedProducts = subcategory.produtos.map((product) {
      return product.copyWith(selecionado: selected);
    }).toList();

    final updatedSubcategory = subcategory.copyWith(produtos: updatedProducts);
    final updatedSubcategories =
        category.subcategorias.asMap().entries.map((entry) {
      return entry.key == subcategoryIndex ? updatedSubcategory : entry.value;
    }).toList();

    categories[categoryIndex] =
        category.copyWith(subcategorias: updatedSubcategories);

    final changedIds = subcategory.produtos.map((p) => p.id).toSet();
    _recalcServicosDependentes(changedIds);
  }

  @action
  void toggleCategoryWithCascade(int categoryId, bool selected) {
    _ensureSnapshot();
    final categoryIndex = categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex == -1) return;

    final category = categories[categoryIndex];

    final updatedSubcategories = category.subcategorias.map((subcategory) {
      final updatedProducts = subcategory.produtos.map((product) {
        return product.copyWith(selecionado: selected);
      }).toList();
      return subcategory.copyWith(produtos: updatedProducts);
    }).toList();

    categories[categoryIndex] =
        category.copyWith(subcategorias: updatedSubcategories);

    final changedIds = <int>{};
    for (final sub in category.subcategorias) {
      for (final prod in sub.produtos) {
        changedIds.add(prod.id);
      }
    }
    _recalcServicosDependentes(changedIds);
  }

  @action
  void updateProductFromModal(ProductEntity updatedProduct) {
    _ensureSnapshot();
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];

        final productIndex =
            subcategory.produtos.indexWhere((p) => p.id == updatedProduct.id);

        if (productIndex != -1) {
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

          _recalcServicosDependentes({updatedProduct.id});
          return;
        }
      }
    }
  }

  @action
  void updateProductQuantity(int productId, double rawQuantity) {
    _ensureSnapshot();
    if (rawQuantity < 1.0) {
      return;
    }

    final quantity = ProductQuantityRules.clamp(rawQuantity);

    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];

        final productIndex =
            subcategory.produtos.indexWhere((p) => p.id == productId);

        if (productIndex != -1) {
          final product = subcategory.produtos[productIndex];

          final updatedProduct = product.copyWith(quantidade: quantity);

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

          _recalcServicosDependentes({productId});
          return;
        }
      }
    }
  }

  @action
  void setProductManualQuantity(int productId, double rawQuantity) {
    _ensureSnapshot();
    if (rawQuantity < 1.0) return;

    final quantity = ProductQuantityRules.clamp(rawQuantity);

    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];
        final productIndex =
            subcategory.produtos.indexWhere((p) => p.id == productId);

        if (productIndex != -1) {
          final product = subcategory.produtos[productIndex];
          final updatedProduct = product.copyWith(
            quantidade: quantity,
            quantidadeManual: true,
          );

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
          _recalcServicosDependentes({productId});
          return;
        }
      }
    }
  }

  /// Alterna o modo de cálculo da quantidade entre manual e por indicadores.
  /// Ao voltar para indicadores (manual=false), recalcula a quantidade.
  @action
  void setProductQuantityMode(int productId, bool manual) {
    _ensureSnapshot();
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];
        final productIndex =
            subcategory.produtos.indexWhere((p) => p.id == productId);

        if (productIndex != -1) {
          final product = subcategory.produtos[productIndex];
          var updatedProduct = product.copyWith(quantidadeManual: manual);

          if (!manual && censoEscolar != null) {
            final todosProdutos = categories
                .expand((c) => c.subcategorias.expand((s) => s.produtos))
                .toList();
            final novaQuantidade = calculationService.calcularQuantidade(
              updatedProduct,
              censoEscolar!,
              todosProdutos: todosProdutos,
            );
            updatedProduct =
                updatedProduct.copyWith(quantidade: novaQuantidade);
          }

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
          if (!manual) {
            _recalcServicosDependentes({productId});
          }
          return;
        }
      }
    }
  }

  @action
  void updateProductValue(int productId, double value) {
    _ensureSnapshot();
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];

        final productIndex =
            subcategory.produtos.indexWhere((p) => p.id == productId);

        if (productIndex != -1) {
          final product = subcategory.produtos[productIndex];

          final updatedProduct = product.copyWith(
            valor: BudgetValueRules.clampUnitValue(value),
          );

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

          return;
        }
      }
    }
  }

  @action
  void updateProductObservations(int productId, String? observations) {
    _ensureSnapshot();
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];

        final productIndex =
            subcategory.produtos.indexWhere((p) => p.id == productId);

        if (productIndex != -1) {
          final product = subcategory.produtos[productIndex];

          final updatedProduct = product.copyWith(observacoes: observations);

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

          return;
        }
      }
    }
  }

  @action
  void toggleProductIndicator(int productId, int indicatorId) {
    _ensureSnapshot();
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];

        final productIndex =
            subcategory.produtos.indexWhere((p) => p.id == productId);

        if (productIndex != -1) {
          final product = subcategory.produtos[productIndex];

          final indicatorIndex = product.indicadoresEtapa
              .indexWhere((ind) => ind.indicadorId == indicatorId);

          if (indicatorIndex != -1) {
            final indicator = product.indicadoresEtapa[indicatorIndex];
            final newSelectedState = !indicator.selecionado;

            final updatedIndicator =
                indicator.copyWith(selecionado: newSelectedState);

            final updatedIndicators =
                List<IndicadorEtapaEntity>.from(product.indicadoresEtapa);
            updatedIndicators[indicatorIndex] = updatedIndicator;

            var updatedProduct =
                product.copyWith(indicadoresEtapa: updatedIndicators);

            if (censoEscolar != null) {
              final todosProdutos = categories
                  .expand((c) => c.subcategorias.expand((s) => s.produtos))
                  .toList();
              final novaQuantidade = calculationService.calcularQuantidade(
                updatedProduct,
                censoEscolar!,
                todosProdutos: todosProdutos,
              );

              updatedProduct = updatedProduct.copyWith(
                quantidade: novaQuantidade,
              );
            }

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

            _recalcServicosDependentes({productId});
            return;
          }
        }
      }
    }
  }

  @action
  void updateProductIndicators(
      int productId, Map<String, List<String>> selectedIndicators) {
    _ensureSnapshot();
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];

        final productIndex =
            subcategory.produtos.indexWhere((p) => p.id == productId);

        if (productIndex != -1) {
          final product = subcategory.produtos[productIndex];

          final updatedProducts =
              List<ProductEntity>.from(subcategory.produtos);

          final updatedSubcategory =
              subcategory.copyWith(produtos: updatedProducts);

          final updatedSubcategories =
              List<SubcategoryEntity>.from(category.subcategorias);
          updatedSubcategories[j] = updatedSubcategory;

          final updatedCategory =
              category.copyWith(subcategorias: updatedSubcategories);

          categories[i] = updatedCategory;

          return;
        }
      }
    }
  }

  void _updateCategoryWithProducts(
    int categoryId,
    List<ProductEntity> products, {
    required bool selected,
  }) {
    final categoryIndex = categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex == -1) return;

    final category = categories[categoryIndex];

    final productsBySubcategory = <int, List<ProductEntity>>{};

    for (final product in products) {
      final subId = product.subcategoriaId;
      productsBySubcategory.putIfAbsent(subId, () => []).add(product);
    }

    productsBySubcategory.forEach((subId, prods) {});

    for (final sub in category.subcategorias) {}

    final updatedSubcategories = category.subcategorias.map((sub) {
      final subcategoryProducts = productsBySubcategory[sub.id] ?? [];

      final updatedProducts = subcategoryProducts
          .map((p) => p.copyWith(
                selecionado: selected,
                quantidade: selected ? 1 : 1,
              ))
          .toList();

      return sub.copyWith(
        produtos: updatedProducts,
        estatisticas: null,
      );
    }).toList();

    final updatedCategory =
        category.copyWith(subcategorias: updatedSubcategories);

    final newCategories = List<CategoryEntity>.from(categories);
    newCategories[categoryIndex] = updatedCategory;
    categories = ObservableList.of(newCategories);
  }

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

  @action
  Future<void> reloadProductsAfterCensusEdit() async {
    _ensureSnapshot();
    if (budgetDetail == null) return;

    if (budgetDetail!.isMultiCity && budgetDetail!.censoAgregado.isNotEmpty) {
      censoEscolar = censoEscolarMapper.buildAggregatedCenso(
        censoAgregado: budgetDetail!.censoAgregado,
        citiesData: budgetDetail!.citiesData,
      );
    } else if (budgetDetail!.citiesData.isNotEmpty) {
      censoEscolar = censoEscolarMapper
          .buildCensoFromCityData(budgetDetail!.citiesData.first);
    }

    _recalculateProductQuantities();
  }

  @action
  void _recalculateProductQuantities() {
    if (censoEscolar == null) return;

    final updated = calculationService.recalcularQuantidadesProdutos(
      categories.toList(),
      censoEscolar!,
    );
    for (var i = 0; i < updated.length; i++) {
      categories[i] = updated[i];
    }
  }

  void _recalcServicosDependentes(Set<int> changedProductIds) {
    if (censoEscolar == null) return;

    final updated = calculationService.recalcularServicosDependentes(
      categories.toList(),
      censoEscolar!,
      changedProductIds,
    );
    for (var i = 0; i < updated.length; i++) {
      if (!identical(updated[i], categories[i])) {
        categories[i] = updated[i];
      }
    }
  }

  /// Captura o snapshot inicial uma única vez, imediatamente antes da
  /// primeira alteração do usuário (estado "padrão" pós-carregamento).
  void _ensureSnapshot() {
    if (_snapshotTaken) return;
    _snapshotInitialProducts();
    _snapshotTaken = true;
  }

  void _snapshotInitialProducts() {
    _origSelecionado.clear();
    _origQuantidade.clear();
    _origQuantidadeManual.clear();
    _origValor.clear();
    _origIndicadores.clear();

    for (final cat in categories) {
      for (final sub in cat.subcategorias) {
        for (final prod in sub.produtos) {
          _origSelecionado[prod.id] = prod.selecionado;
          _origQuantidade[prod.id] = prod.quantidade;
          _origQuantidadeManual[prod.id] = prod.quantidadeManual;
          _origValor[prod.id] = prod.valor;
          final indicatorMap = <int, bool>{};
          for (final ind in prod.indicadoresEtapa) {
            indicatorMap[ind.produtoIndicadorId] = ind.selecionado;
          }
          _origIndicadores[prod.id] = indicatorMap;
        }
      }
    }
  }

  bool _isProductChanged(ProductEntity prod) {
    if (_origSelecionado[prod.id] != prod.selecionado) return true;
    if ((_origQuantidade[prod.id] ?? 0) != prod.quantidade) return true;
    if (_origQuantidadeManual[prod.id] != prod.quantidadeManual) return true;
    if ((_origValor[prod.id] ?? 0) != prod.valor) return true;

    final origInds = _origIndicadores[prod.id];
    if (origInds != null) {
      for (final ind in prod.indicadoresEtapa) {
        if (origInds[ind.produtoIndicadorId] != ind.selecionado) {
          return true;
        }
      }
    }

    return false;
  }

  Set<int> _changedIndicatorIds(ProductEntity prod) {
    final changed = <int>{};
    final origInds = _origIndicadores[prod.id];
    if (origInds == null) return changed;
    for (final ind in prod.indicadoresEtapa) {
      if (origInds[ind.produtoIndicadorId] != ind.selecionado) {
        changed.add(ind.produtoIndicadorId);
      }
    }
    return changed;
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
    _originalValidityDays = null;
    _snapshotTaken = false;
    _validityDateChanged = false;
    _origSelecionado.clear();
    _origQuantidade.clear();
    _origQuantidadeManual.clear();
    _origValor.clear();
    _origIndicadores.clear();
  }

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

    if (BudgetValueRules.exceedsMaxTotal(totalValue)) {
      const failure = ValidationFailure(BudgetValueRules.totalExceededMessage);
      error = failure.message;
      return const Left(failure);
    }

    isSaving = true;
    error = null;

    try {
      _ensureSnapshot();

      final produtosParaSalvar = <ProductSelectionUpdateDto>[];

      for (final category in categories) {
        for (final subcategory in category.subcategorias) {
          for (final product in subcategory.produtos) {
            if (_isProductChanged(product)) {
              final changedIndIds = _changedIndicatorIds(product);
              produtosParaSalvar.add(
                ProductSelectionUpdateDto.delta(
                  entity: product,
                  selecionadoChanged:
                      _origSelecionado[product.id] != product.selecionado,
                  quantidadeChanged:
                      (_origQuantidade[product.id] ?? 0) != product.quantidade,
                  valorChanged: (_origValor[product.id] ?? 0) != product.valor,
                  changedIndicatorIds: changedIndIds,
                ),
              );
            }
          }
        }
      }

      final totalCalculado = totalValue;

      int diasValidade;
      if (_validityDateChanged) {
        final hoje = DateTime.now();
        final hojeNormalizado = DateTime(hoje.year, hoje.month, hoje.day);
        final validadeNormalizada = DateTime(
            validityDate!.year, validityDate!.month, validityDate!.day);
        diasValidade = validadeNormalizada.difference(hojeNormalizado).inDays;
      } else {
        diasValidade = _originalValidityDays ?? budgetDetail!.validityDays;
      }

      final updateDto = BudgetUpdateDto(
        nome: budgetName,
        diasValidade: diasValidade > 0 ? diasValidade : 1,
        status: 'pendente',
        total: totalCalculado,
        usuarioId: budgetDetail!.userId,
        partnerDestinoId: budgetDetail!.partnerId,
        cidades: budgetDetail!.cityIds,
        isArchived: budgetDetail!.isArchived,
        produtos: produtosParaSalvar,
      );

      final result = await saveBudgetUseCase(
        budgetId: budgetDetail!.id,
        updateData: updateDto,
      );

      return result.fold(
        (failure) {
          error = failure.message;
          isSaving = false;
          return Left(failure);
        },
        (updatedBudget) {
          // Backend pode responder apenas com status de sucesso (sem corpo):
          // nesse caso mantemos o estado local já atualizado.
          if (updatedBudget != null) {
            budgetDetail = updatedBudget;
          }
          isSaving = false;
          return Right(budgetDetail!);
        },
      );
    } catch (_) {
      error = budgetSaveErrorMessage;
      isSaving = false;
      return const Left(UnknownFailure(budgetSaveErrorMessage));
    }
  }
}
