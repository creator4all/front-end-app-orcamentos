import 'package:dartz/dartz.dart';
import 'package:mobx/mobx.dart';

import '../../../../auth/presentation/stores/auth_store.dart';
import '../../../budget_config/data/models/category_dto.dart';
import '../../../budget_config/domain/entities/budget_detail_entity.dart';
import '../../../budget_config/domain/entities/category_entity.dart';
import '../../../budget_config/domain/entities/censo_escolar_entity.dart';
import '../../../budget_config/domain/entities/censo_group_entity.dart';
import '../../../budget_config/domain/entities/censo_title_entity.dart';
import '../../../budget_config/domain/entities/census_data_entity.dart';
import '../../../budget_config/domain/entities/indicador_etapa_entity.dart';
import '../../../budget_config/domain/entities/product_entity.dart';
import '../../../budget_config/domain/entities/subcategory_entity.dart';
import '../../../budget_config/domain/services/product_calculation_service.dart';
import '../../../budget_config/domain/usecases/get_census_data_usecase.dart';
import '../../../shared/errors/budget_failure.dart';
import '../../../shared/models/budget_update_dto.dart';
import '../../../shared/models/product_selection_update_dto.dart';
import '../../domain/entities/budget_edit_entity.dart';
import '../../domain/usecases/get_budget_for_edit_usecase.dart';
import '../../domain/usecases/update_budget_usecase.dart';

part 'budget_edit_store.g.dart';

class BudgetEditStore = _BudgetEditStoreBase with _$BudgetEditStore;

abstract class _BudgetEditStoreBase with Store {
  final GetBudgetForEditUseCase getBudgetForEditUseCase;
  final UpdateBudgetUseCase updateBudgetUseCase;
  final GetCensusDataUseCase getCensusDataUseCase;
  final AuthStore authStore;
  final ProductCalculationService calculationService;

  _BudgetEditStoreBase({
    required this.getBudgetForEditUseCase,
    required this.updateBudgetUseCase,
    required this.getCensusDataUseCase,
    required this.authStore,
    required this.calculationService,
  });

  @observable
  bool isLoading = false;

  @observable
  bool isSaving = false;

  @observable
  bool isLoadingProducts = false;

  @observable
  bool isLoadingCensus = false;

  @observable
  String? error;

  @observable
  BudgetEditEntity? budgetData;

  @observable
  String selectedStatus = 'pendente';

  @observable
  bool isArchived = false;

  @observable
  DateTime? validityDate;

  /// Valor original de dias_validade recebido do backend
  int? _originalValidityDays;

  /// Indica se o usuário alterou a data de validade nesta sessão de edição
  bool _validityDateChanged = false;

  Set<int> _originalSelectedProductIds = {};
  String _originalStatus = 'pendente';
  bool _originalIsArchived = false;
  DateTime? _originalValidityDate;
  final Map<int, double> _originalProductQuantities = {};
  final Map<int, bool> _originalProductManualFlags = {};
  final Map<int, double> _originalProductValues = {};
  final Map<int, String?> _originalProductObservations = {};
  final Map<int, Map<int, bool>> _originalProductIndicators = {};

  int _loadRequestVersion = 0;

  @observable
  String? budgetName;

  @observable
  ObservableSet<int> selectedProductIds = ObservableSet<int>();

  @observable
  ObservableList<CategoryEntity> categories = ObservableList<CategoryEntity>();

  @observable
  CategoryEntity? selectedCategory;

  @observable
  SubcategoryEntity? selectedSubcategory;

  @observable
  CensusDataEntity? censusData;

  @observable
  CensoEscolarEntity? censoEscolar;

  @observable
  ObservableList<ProductEntity> productsNeedingRemark =
      ObservableList<ProductEntity>();

  @computed
  bool get hasChanges {
    if (selectedProductIds.length != _originalSelectedProductIds.length)
      return true;
    if (!selectedProductIds.containsAll(_originalSelectedProductIds))
      return true;
    if (selectedStatus != _originalStatus) return true;
    if (isArchived != _originalIsArchived) return true;
    if (validityDate != _originalValidityDate) return true;

    for (final cat in categories) {
      for (final sub in cat.subcategorias) {
        for (final prod in sub.produtos) {
          if (_originalProductQuantities[prod.id] != prod.quantidade) {
            return true;
          }
          if (_originalProductManualFlags[prod.id] != prod.quantidadeManual) {
            return true;
          }
          if (_originalProductValues[prod.id] != prod.valor) return true;
          if (_originalProductObservations[prod.id] != prod.observacoes)
            return true;

          final origIndicators = _originalProductIndicators[prod.id];
          if (origIndicators != null) {
            for (final ind in prod.indicadoresEtapa) {
              if (origIndicators[ind.produtoIndicadorId] != ind.selecionado) {
                return true;
              }
            }
          }
        }
      }
    }

    return false;
  }

  @computed
  bool get hasData => budgetData != null;

  @computed
  bool get canSave {
    if (budgetData == null) return false;
    if (validityDate == null) return false;
    return selectedProductIds.isNotEmpty;
  }

  @computed
  int get selectedProductsCount => selectedProductIds.length;

  @computed
  double get totalValue {
    return categories.fold(0.0, (sum, c) => sum + c.totalValue);
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
  int get selectedCategoriesCount {
    return categories.where((c) => c.hasSelectedProducts).length;
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
  bool get hasCategories => categories.isNotEmpty;

  @computed
  bool get hasCensusData => censusData != null && censusData!.hasData;

  @computed
  bool get isFullyLoaded => !isLoading && !isLoadingProducts;

  @action
  Future<void> initialize(int budgetId) async {
    await loadBudgetForEdit(budgetId);
  }

  @action
  Future<void> loadBudgetForEdit(int budgetId) async {
    final requestVersion = ++_loadRequestVersion;

    _clearBudgetStateForLoading();
    isLoading = true;
    isLoadingProducts = true;

    try {
      final result = await getBudgetForEditUseCase(budgetId);

      if (requestVersion != _loadRequestVersion) {
        return;
      }

      result.fold(
        (failure) {
          error = failure.message;
          budgetData = null;
          isLoading = false;
          isLoadingProducts = false;
        },
        (budget) {
          _applyLoadedBudget(budget);
        },
      );
    } catch (e) {
      if (requestVersion != _loadRequestVersion) {
        return;
      }
      error = 'Erro ao carregar orçamento: $e';
      isLoading = false;
      isLoadingProducts = false;
    }
  }

  void initializeWithConfiguredBudget(BudgetDetailEntity configuredBudget) {
    _loadRequestVersion++;

    runInAction(() {
      _clearBudgetStateForLoading();
      _applyLoadedBudget(
        BudgetEditEntity.fromBudgetDetail(configuredBudget),
      );
    });
  }

  void _applyLoadedBudget(BudgetEditEntity budget) {
    budgetData = budget;

    categories.clear();
    categories.addAll(_parseCategoriesFromBudget(budget));

    selectedStatus = budget.status;
    isArchived = budget.isArchived;
    validityDate = budget.validityDate;
    budgetName = budget.name;
    _originalValidityDays = budget.validityDays;
    _validityDateChanged = false;

    _updateSelectedProductIds();

    _parseCensoEscolarFromCitiesData();
    _recalculateProductQuantities();
    _snapshotOriginalState();

    isLoading = false;
    isLoadingProducts = false;
  }

  void _updateSelectedProductIds() {
    selectedProductIds.clear();

    for (final cat in categories) {
      for (final sub in cat.subcategorias) {
        for (final prod in sub.produtos) {
          if (prod.selecionado) {
            selectedProductIds.add(prod.id);
          }
        }
      }
    }
  }

  List<CategoryEntity> _parseCategoriesFromBudget(BudgetEditEntity budget) {
    try {
      if (budget.categoriesData is! List) {
        return [];
      }

      final categoriesList = budget.categoriesData as List<dynamic>;

      final List<CategoryEntity> categories = [];

      for (var i = 0; i < categoriesList.length; i++) {
        try {
          final rawCategory = categoriesList[i];
          if (rawCategory is CategoryEntity) {
            categories.add(rawCategory);
            continue;
          }

          final categoryJson = rawCategory as Map<String, dynamic>;

          final categoryDto = CategoryDTO.fromJson(categoryJson);
          final categoryEntity = categoryDto.toEntity();

          categories.add(categoryEntity);
        } catch (_) {
          continue;
        }
      }

      return categories;
    } catch (e) {
      return [];
    }
  }

  @action
  Future<void> loadCensusData(int cityId) async {
    isLoadingCensus = true;

    try {
      final result = await getCensusDataUseCase(cityId);

      result.fold(
        (failure) {
          error = failure.message;
        },
        (data) {
          censusData = data;
        },
      );
    } catch (_) {
      error = 'Erro ao carregar dados de censo';
    } finally {
      isLoadingCensus = false;
    }
  }

  @action
  void selectCategory(CategoryEntity category) {
    selectedCategory = category;
    selectedSubcategory = null;
  }

  @action
  void selectSubcategory(SubcategoryEntity subcategory) {
    selectedSubcategory = subcategory;
  }

  @action
  void toggleProductInCategory(int categoryId, int productId, bool selected) {
    if (selected) {
      selectedProductIds.add(productId);
    } else {
      selectedProductIds.remove(productId);
    }
  }

  @action
  void toggleProductSelection(int productId) {
    if (selectedProductIds.contains(productId)) {
      selectedProductIds.remove(productId);
    } else {
      selectedProductIds.add(productId);
    }
  }

  @action
  void selectAllProductsForSubcategory(int subcategoryId, bool selected) {
    if (budgetData == null) return;

    final products = budgetData!.products.where(
      (p) => p.category.contains(subcategoryId.toString()),
    );

    if (selected) {
      selectedProductIds.addAll(products.map((p) => p.productId));
    } else {
      for (final product in products) {
        selectedProductIds.remove(product.productId);
      }
    }
  }

  @action
  void setStatus(String status) {
    selectedStatus = status;
  }

  @action
  void setArchived(bool archived) {
    isArchived = archived;
  }

  @action
  void setValidityDate(DateTime? date) {
    validityDate = date;
    _validityDateChanged = true;
    if (selectedStatus == 'expirado') {
      selectedStatus = 'pendente';
    }
  }

  @action
  Future<Either<BudgetFailure, BudgetEditEntity>> saveBudget() async {
    return saveBudgetWithDto();
  }

  @action
  void reset() {
    _loadRequestVersion++;
    _clearBudgetStateForLoading();
    isLoading = false;
    isSaving = false;
    isLoadingProducts = false;
    isLoadingCensus = false;
  }

  @action
  void clearError() {
    error = null;
  }

  void _clearBudgetStateForLoading() {
    budgetData = null;
    selectedProductIds.clear();
    categories.clear();
    selectedCategory = null;
    selectedSubcategory = null;
    censusData = null;
    censoEscolar = null;
    productsNeedingRemark.clear();
    selectedStatus = 'pendente';
    isArchived = false;
    validityDate = null;
    budgetName = null;
    error = null;
    _originalValidityDays = null;
    _validityDateChanged = false;
    _originalSelectedProductIds.clear();
    _originalStatus = 'pendente';
    _originalIsArchived = false;
    _originalValidityDate = null;
    _originalProductQuantities.clear();
    _originalProductManualFlags.clear();
    _originalProductValues.clear();
    _originalProductObservations.clear();
    _originalProductIndicators.clear();
  }

  @action
  void toggleCategoryWithCascade(int categoryId, bool selected) {
    final categoryIndex = categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex == -1) return;

    final category = categories[categoryIndex];

    final updatedCategory = category.copyWith(
      subcategorias: category.subcategorias.map((sub) {
        return sub.copyWith(
          produtos: sub.produtos.map((prod) {
            return prod.copyWith(selecionado: selected);
          }).toList(),
        );
      }).toList(),
    );

    categories[categoryIndex] = updatedCategory;

    if (selected) {
      for (final sub in updatedCategory.subcategorias) {
        for (final prod in sub.produtos) {
          selectedProductIds.add(prod.id);
        }
      }
    } else {
      for (final sub in updatedCategory.subcategorias) {
        for (final prod in sub.produtos) {
          selectedProductIds.remove(prod.id);
        }
      }
    }

    final changedIds = <int>{};
    for (final sub in category.subcategorias) {
      for (final prod in sub.produtos) {
        changedIds.add(prod.id);
      }
    }
    _recalcServicosDependentes(changedIds);
  }

  @action
  void toggleSubcategoryWithCascade(
    int categoryId,
    int subcategoryId,
    bool selected,
  ) {
    final categoryIndex = categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex == -1) return;

    final category = categories[categoryIndex];
    final subIndex = category.subcategorias.indexWhere(
      (s) => s.id == subcategoryId,
    );
    if (subIndex == -1) return;

    final subcategory = category.subcategorias[subIndex];

    final updatedSubcategory = subcategory.copyWith(
      produtos: subcategory.produtos.map((prod) {
        return prod.copyWith(selecionado: selected);
      }).toList(),
    );

    final updatedSubcategories = List<SubcategoryEntity>.from(
      category.subcategorias,
    );
    updatedSubcategories[subIndex] = updatedSubcategory;

    final updatedCategory = category.copyWith(
      subcategorias: updatedSubcategories,
    );

    categories[categoryIndex] = updatedCategory;

    if (selected) {
      for (final prod in updatedSubcategory.produtos) {
        selectedProductIds.add(prod.id);
      }
    } else {
      for (final prod in updatedSubcategory.produtos) {
        selectedProductIds.remove(prod.id);
      }
    }

    final changedIds = subcategory.produtos.map((p) => p.id).toSet();
    _recalcServicosDependentes(changedIds);
  }

  @action
  void toggleProduct(int productId, bool selected) {
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];
        final prodIndex = subcategory.produtos.indexWhere(
          (p) => p.id == productId,
        );

        if (prodIndex != -1) {
          final product = subcategory.produtos[prodIndex];
          var updatedProduct = product.copyWith(selecionado: selected);

          if (selected &&
              censoEscolar != null &&
              !updatedProduct.quantidadeManual) {
            final todosProdutos = categories
                .expand((c) => c.subcategorias.expand((s) => s.produtos))
                .toList();
            final novaQuantidade = calculationService.calcularQuantidade(
              updatedProduct,
              censoEscolar,
              todosProdutos: todosProdutos,
            );
            updatedProduct = updatedProduct.copyWith(
              quantidade: novaQuantidade,
            );
          }

          final updatedProducts = List<ProductEntity>.from(
            subcategory.produtos,
          );
          updatedProducts[prodIndex] = updatedProduct;

          final updatedSubcategory = subcategory.copyWith(
            produtos: updatedProducts,
          );

          final updatedSubcategories = List<SubcategoryEntity>.from(
            category.subcategorias,
          );
          updatedSubcategories[j] = updatedSubcategory;

          final updatedCategory = category.copyWith(
            subcategorias: updatedSubcategories,
          );

          categories[i] = updatedCategory;

          if (selected) {
            selectedProductIds.add(productId);
          } else {
            selectedProductIds.remove(productId);
          }

          _recalcServicosDependentes({productId});
          return;
        }
      }
    }
  }

  @action
  void updateProductValue(int productId, double value) {
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];
        final prodIndex = subcategory.produtos.indexWhere(
          (p) => p.id == productId,
        );

        if (prodIndex != -1) {
          final product = subcategory.produtos[prodIndex];

          final updatedProduct = product.copyWith(valor: value);

          final updatedProducts = List<ProductEntity>.from(
            subcategory.produtos,
          );
          updatedProducts[prodIndex] = updatedProduct;

          final updatedSubcategory = subcategory.copyWith(
            produtos: updatedProducts,
          );

          final updatedSubcategories = List<SubcategoryEntity>.from(
            category.subcategorias,
          );
          updatedSubcategories[j] = updatedSubcategory;

          final updatedCategory = category.copyWith(
            subcategorias: updatedSubcategories,
          );

          categories[i] = updatedCategory;
          return;
        }
      }
    }
  }

  @action
  void updateProductQuantity(int productId, double quantity) {
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];
        final prodIndex = subcategory.produtos.indexWhere(
          (p) => p.id == productId,
        );

        if (prodIndex != -1) {
          final product = subcategory.produtos[prodIndex];
          final updatedProduct = product.copyWith(quantidade: quantity);

          final updatedProducts = List<ProductEntity>.from(
            subcategory.produtos,
          );
          updatedProducts[prodIndex] = updatedProduct;

          final updatedSubcategory = subcategory.copyWith(
            produtos: updatedProducts,
          );

          final updatedSubcategories = List<SubcategoryEntity>.from(
            category.subcategorias,
          );
          updatedSubcategories[j] = updatedSubcategory;

          final updatedCategory = category.copyWith(
            subcategorias: updatedSubcategories,
          );

          categories[i] = updatedCategory;
          _recalcServicosDependentes({productId});
          return;
        }
      }
    }
  }

  /// Define a quantidade manualmente para um produto, ativando o modo manual
  /// (a quantidade passa a ignorar os indicadores).
  @action
  void setProductManualQuantity(int productId, double quantity) {
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];
        final prodIndex = subcategory.produtos.indexWhere(
          (p) => p.id == productId,
        );

        if (prodIndex != -1) {
          final product = subcategory.produtos[prodIndex];
          final updatedProduct = product.copyWith(
            quantidade: quantity,
            quantidadeManual: true,
          );

          final updatedProducts = List<ProductEntity>.from(
            subcategory.produtos,
          );
          updatedProducts[prodIndex] = updatedProduct;

          final updatedSubcategory = subcategory.copyWith(
            produtos: updatedProducts,
          );

          final updatedSubcategories = List<SubcategoryEntity>.from(
            category.subcategorias,
          );
          updatedSubcategories[j] = updatedSubcategory;

          final updatedCategory = category.copyWith(
            subcategorias: updatedSubcategories,
          );

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
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];
        final prodIndex = subcategory.produtos.indexWhere(
          (p) => p.id == productId,
        );

        if (prodIndex != -1) {
          final product = subcategory.produtos[prodIndex];
          var updatedProduct = product.copyWith(quantidadeManual: manual);

          if (!manual) {
            // Voltar ao cálculo por indicadores: recalcular a quantidade
            final novaQuantidade = calculationService.calcularQuantidade(
              updatedProduct,
              censoEscolar,
            );
            updatedProduct = updatedProduct.copyWith(
              quantidade: novaQuantidade,
            );
          }

          final updatedProducts = List<ProductEntity>.from(
            subcategory.produtos,
          );
          updatedProducts[prodIndex] = updatedProduct;

          final updatedSubcategory = subcategory.copyWith(
            produtos: updatedProducts,
          );

          final updatedSubcategories = List<SubcategoryEntity>.from(
            category.subcategorias,
          );
          updatedSubcategories[j] = updatedSubcategory;

          final updatedCategory = category.copyWith(
            subcategorias: updatedSubcategories,
          );

          categories[i] = updatedCategory;
          _recalcServicosDependentes({productId});
          return;
        }
      }
    }
  }

  @action
  void updateProductObservations(int productId, String observations) {
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];
        final prodIndex = subcategory.produtos.indexWhere(
          (p) => p.id == productId,
        );

        if (prodIndex != -1) {
          final product = subcategory.produtos[prodIndex];
          final updatedProduct = product.copyWith(observacoes: observations);

          final updatedProducts = List<ProductEntity>.from(
            subcategory.produtos,
          );
          updatedProducts[prodIndex] = updatedProduct;

          final updatedSubcategory = subcategory.copyWith(
            produtos: updatedProducts,
          );

          final updatedSubcategories = List<SubcategoryEntity>.from(
            category.subcategorias,
          );
          updatedSubcategories[j] = updatedSubcategory;

          final updatedCategory = category.copyWith(
            subcategorias: updatedSubcategories,
          );

          categories[i] = updatedCategory;
          return;
        }
      }
    }
  }

  @action
  void toggleProductIndicator(int productId, int indicatorId) {
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];

        final productIndex = subcategory.produtos.indexWhere(
          (p) => p.id == productId,
        );

        if (productIndex != -1) {
          final product = subcategory.produtos[productIndex];

          final indicatorIndex = product.indicadoresEtapa
              .indexWhere((ind) => ind.indicadorId == indicatorId);

          if (indicatorIndex != -1) {
            final indicator = product.indicadoresEtapa[indicatorIndex];
            final newSelectedState = !indicator.selecionado;

            final updatedIndicator = indicator.copyWith(
              selecionado: newSelectedState,
            );

            final updatedIndicators = List<IndicadorEtapaEntity>.from(
              product.indicadoresEtapa,
            );
            updatedIndicators[indicatorIndex] = updatedIndicator;

            var updatedProduct = product.copyWith(
              indicadoresEtapa: updatedIndicators,
            );

            if (censoEscolar != null && !updatedProduct.quantidadeManual) {
              final todosProdutos = categories
                  .expand((c) => c.subcategorias.expand((s) => s.produtos))
                  .toList();
              final novaQuantidade = calculationService.calcularQuantidade(
                updatedProduct,
                censoEscolar,
                todosProdutos: todosProdutos,
              );

              updatedProduct = updatedProduct.copyWith(
                quantidade: novaQuantidade,
              );
            }

            final updatedProducts = List<ProductEntity>.from(
              subcategory.produtos,
            );
            updatedProducts[productIndex] = updatedProduct;

            final updatedSubcategory = subcategory.copyWith(
              produtos: updatedProducts,
            );

            final updatedSubcategories = List<SubcategoryEntity>.from(
              category.subcategorias,
            );
            updatedSubcategories[j] = updatedSubcategory;

            final updatedCategory = category.copyWith(
              subcategorias: updatedSubcategories,
            );

            categories[i] = updatedCategory;

            _recalcServicosDependentes({productId});
            return;
          }
        }
      }
    }
  }

  @action
  Future<Either<BudgetFailure, BudgetEditEntity>> saveBudgetWithDto() async {
    if (budgetData == null) {
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
      final produtosParaSalvar = <ProductSelectionUpdateDto>[];

      for (final category in categories) {
        for (final subcategory in category.subcategorias) {
          for (final product in subcategory.produtos) {
            produtosParaSalvar.add(
              ProductSelectionUpdateDto.fromEntity(product),
            );
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
        diasValidade = _originalValidityDays ?? budgetData!.validityDays;
      }

      final isMultiCity = budgetData!.isMultiCity;

      final updateDto = BudgetUpdateDto(
        nome: budgetName,
        diasValidade: diasValidade > 0 ? diasValidade : 1,
        status: selectedStatus,
        isArchived: isArchived,
        total: totalCalculado,
        usuarioId: authStore.currentUser?.id ?? budgetData!.userId,
        cidadeId: isMultiCity ? null : budgetData!.cityIds.firstOrNull,
        cidades: isMultiCity ? budgetData!.cityIds : null,
        produtos: produtosParaSalvar,
        partnerDestinoId: budgetData!.partnerId,
      );

      final Either<BudgetFailure, BudgetEditEntity> result;
      if (isMultiCity) {
        result = await updateBudgetUseCase.versionMultiCityWithDto(
          budgetId: budgetData!.id,
          updateData: updateDto,
        );
      } else {
        result = await updateBudgetUseCase.versionWithDto(
          budgetId: budgetData!.id,
          updateData: updateDto,
        );
      }

      return result.fold(
        (failure) {
          error = failure.message;
          isSaving = false;
          return Left(failure);
        },
        (updatedBudget) {
          budgetData = updatedBudget;
          isSaving = false;
          return Right(updatedBudget);
        },
      );
    } catch (e) {
      error = 'Erro ao salvar orçamento: $e';
      isSaving = false;
      return Left(UnknownFailure(e.toString()));
    }
  }

  void _snapshotOriginalState() {
    _originalSelectedProductIds = Set<int>.from(selectedProductIds);
    _originalStatus = selectedStatus;
    _originalIsArchived = isArchived;
    _originalValidityDate = validityDate;

    _originalProductQuantities.clear();
    _originalProductManualFlags.clear();
    _originalProductValues.clear();
    _originalProductObservations.clear();
    _originalProductIndicators.clear();

    for (final cat in categories) {
      for (final sub in cat.subcategorias) {
        for (final prod in sub.produtos) {
          _originalProductQuantities[prod.id] = prod.quantidade;
          _originalProductManualFlags[prod.id] = prod.quantidadeManual;
          _originalProductValues[prod.id] = prod.valor;
          _originalProductObservations[prod.id] = prod.observacoes;
          final indicatorMap = <int, bool>{};
          for (final ind in prod.indicadoresEtapa) {
            indicatorMap[ind.produtoIndicadorId] = ind.selecionado;
          }
          _originalProductIndicators[prod.id] = indicatorMap;
        }
      }
    }
  }

  void _updateOriginalQuantitiesSnapshot() {
    _originalProductQuantities.clear();

    for (final cat in categories) {
      for (final sub in cat.subcategorias) {
        for (final prod in sub.produtos) {
          _originalProductQuantities[prod.id] = prod.quantidade;
        }
      }
    }
  }

  void _parseCensoEscolarFromCitiesData() {
    if (budgetData == null) {
      censoEscolar = null;
      return;
    }

    if (budgetData!.censoAgregado.isNotEmpty) {
      censoEscolar = _buildAggregatedCenso(
        censoAgregado: budgetData!.censoAgregado,
        citiesData: budgetData!.citiesDataRaw,
      );
      return;
    }

    if (budgetData!.citiesDataRaw.isEmpty) {
      censoEscolar = null;
      return;
    }

    try {
      final cityData = budgetData!.citiesDataRaw.first;
      censoEscolar = _buildCensoFromCityData(cityData);
    } catch (e) {
      censoEscolar = null;
    }
  }

  @action
  void updateCensoEscolar(CensoEscolarEntity updatedCenso) {
    censoEscolar = updatedCenso;

    if (budgetData != null && budgetData!.citiesDataRaw.isNotEmpty) {
      var cityUpdated = false;
      final updatedCitiesData = budgetData!.citiesDataRaw.map((cityData) {
        final cityId = _toInt(cityData['idCidades'] ?? cityData['id']);
        if (cityId == updatedCenso.cidadeId && updatedCenso.cidadeId > 0) {
          cityUpdated = true;
          return _updateCityDataWithCenso(cityData, updatedCenso);
        }
        return cityData;
      }).toList();

      if (!cityUpdated && updatedCenso.cidadeId > 0) {
        updatedCitiesData.add(
          _updateCityDataWithCenso(<String, dynamic>{}, updatedCenso),
        );
      }

      final updatedCensoAgregado = _calculateAggregatedCensoFromCities(
        updatedCitiesData,
        budgetData!.censoAgregado,
      );

      budgetData = budgetData!.copyWith(
        citiesDataRaw: updatedCitiesData,
        censoAgregado: updatedCensoAgregado,
      );
    } else if (budgetData != null && updatedCenso.cidadeId > 0) {
      final newCityData =
          _updateCityDataWithCenso(<String, dynamic>{}, updatedCenso);
      budgetData = budgetData!.copyWith(
        citiesDataRaw: [newCityData],
        censoAgregado: Map<String, double>.from(updatedCenso.valoresPorEtapa),
      );
    }
  }

  @action
  Future<void> reloadProductsAfterCensusEdit() async {
    if (budgetData == null) return;

    _parseCensoEscolarFromCitiesData();
    _recalculateProductQuantities();
    _updateOriginalQuantitiesSnapshot();
    budgetData = budgetData?.copyWith(total: totalValue);
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

  Map<int, List<int>> _buildServiceDependencyIndex() {
    final index = <int, List<int>>{};
    for (final cat in categories) {
      for (final sub in cat.subcategorias) {
        for (final prod in sub.produtos) {
          if (prod.produtosRelacionadosIds.isNotEmpty) {
            for (final linkedId in prod.produtosRelacionadosIds) {
              index.putIfAbsent(linkedId, () => []).add(prod.id);
            }
          }
        }
      }
    }
    return index;
  }

  void _recalcServicosDependentes(Set<int> changedProductIds) {
    if (censoEscolar == null) return;

    final depIndex = _buildServiceDependencyIndex();
    final affectedServiceIds = <int>{};
    for (final pid in changedProductIds) {
      affectedServiceIds.addAll(depIndex[pid] ?? []);
    }
    if (affectedServiceIds.isEmpty) return;

    final todosProdutos = categories
        .expand((c) => c.subcategorias.expand((s) => s.produtos))
        .toList();

    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];
      var categoryChanged = false;
      final updatedSubs = List<SubcategoryEntity>.from(category.subcategorias);

      for (var j = 0; j < updatedSubs.length; j++) {
        final sub = updatedSubs[j];
        var subChanged = false;
        final updatedProds = List<ProductEntity>.from(sub.produtos);

        for (var k = 0; k < updatedProds.length; k++) {
          final prod = updatedProds[k];
          if (!affectedServiceIds.contains(prod.id)) continue;
          if (!prod.selecionado) continue;
          if (prod.quantidadeManual) continue;

          final novaQtd = calculationService.calcularQuantidadeServico(
            prod,
            todosProdutos,
            censoEscolar!,
          );
          if (novaQtd != prod.quantidade) {
            updatedProds[k] = prod.copyWith(quantidade: novaQtd);
            subChanged = true;
          }
        }

        if (subChanged) {
          updatedSubs[j] = sub.copyWith(produtos: updatedProds);
          categoryChanged = true;
        }
      }

      if (categoryChanged) {
        categories[i] = category.copyWith(subcategorias: updatedSubs);
      }
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
            final updatedProduct = product.copyWith(
              quantidade: newQuantity,
            );
            productsToRemark.add(updatedProduct);
          }
        }
      }
    }

    productsNeedingRemark.clear();
    productsNeedingRemark.addAll(productsToRemark);

    if (productsToRemark.isNotEmpty) {}
  }

  @action
  void confirmProductRemark() {
    if (productsNeedingRemark.isEmpty) return;

    final productsToRemark = List<ProductEntity>.from(productsNeedingRemark);

    for (final product in productsToRemark) {
      toggleProduct(product.id, true);
    }

    productsNeedingRemark.clear();
  }

  @action
  void rejectProductRemark() {
    if (productsNeedingRemark.isEmpty) return;

    productsNeedingRemark.clear();
  }

  Map<String, dynamic> _updateCityDataWithCenso(
    Map<String, dynamic> cityData,
    CensoEscolarEntity updatedCenso,
  ) {
    final indices = _buildIndicesFromCenso(updatedCenso);
    final existingName = cityData['nome'] ?? cityData['nome_cidade'];
    final cityName = existingName == null || existingName.toString().isEmpty
        ? updatedCenso.cidadeNome
        : existingName.toString();

    return {
      ...cityData,
      'id': _toInt(cityData['id'] ?? cityData['idCidades']) > 0
          ? _toInt(cityData['id'] ?? cityData['idCidades'])
          : updatedCenso.cidadeId,
      'nome': cityName,
      'indices': indices,
      'indicadores': _buildIndicadoresFromIndices(indices),
      'cidades_has_indice_etapa':
          _buildLegacyIndicesFromIndices(indices, updatedCenso.cidadeId),
    };
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  List<Map<String, dynamic>> _extractIndicesFromCityData(
    Map<String, dynamic> cityData,
  ) {
    final rawIndices = cityData['indices'] as List? ??
        cityData['indicadores'] as List? ??
        cityData['cidades_has_indice_etapa'] as List? ??
        const [];

    return rawIndices
        .whereType<Map>()
        .map((item) => _normalizeCityIndice(Map<String, dynamic>.from(item)))
        .where((item) => item['nome_etapa'].toString().isNotEmpty)
        .toList();
  }

  Map<String, dynamic> _normalizeCityIndice(Map<String, dynamic> item) {
    final group = item['grupo'] as Map<String, dynamic>?;
    final pivot = item['pivot'] as Map<String, dynamic>?;

    final groupId = _toInt(
      item['grupo_id'] ??
          item['grupos_grupo_id'] ??
          group?['id'] ??
          group?['grupo_id'],
    );
    final groupName =
        (item['grupo_nome'] ?? group?['nome'] ?? group?['nome_grupo'] ?? '')
            .toString();
    final nomeEtapa = (item['nome_etapa'] ?? item['nome'] ?? '').toString();
    final titulo = (item['titulo'] ??
            item['titulo_etapa'] ??
            item['nome'] ??
            item['nome_etapa'] ??
            '')
        .toString();
    final valor = _toDouble(
      item['valor'] ?? item['etapa_valor'] ?? pivot?['etapa_valor'],
    );

    return <String, dynamic>{
      'id': _toInt(
        item['id'] ??
            item['idindice_etapa'] ??
            item['indice_etapa_id'] ??
            item['indice_etapa_idindice_etapa'],
      ),
      'nome_etapa': nomeEtapa,
      'titulo': titulo,
      'valor': valor,
      'percentual_populacao': item['percentual_populacao'],
      'grupo': {
        'id': groupId,
        'nome': groupName,
      },
    };
  }

  CensoEscolarEntity? _buildCensoFromCityData(Map<String, dynamic> cityData) {
    final normalizedIndices = _extractIndicesFromCityData(cityData);
    if (normalizedIndices.isEmpty) return null;

    final valoresPorEtapa = <String, double>{};
    final gruposMap = <int, List<CensoTitleEntity>>{};
    final grupoNomes = <int, String>{};

    for (final indice in normalizedIndices) {
      final nomeEtapa = indice['nome_etapa'].toString();
      final titulo = indice['titulo'].toString();
      final valor = _toDouble(indice['valor']);
      final group = indice['grupo'] as Map<String, dynamic>? ?? const {};
      final grupoId = _toInt(group['id']);
      final grupoNome = (group['nome'] ?? '').toString();
      final id = _toInt(indice['id']);

      valoresPorEtapa[nomeEtapa] = valor;
      grupoNomes[grupoId] = grupoNome;
      gruposMap.putIfAbsent(grupoId, () => []);
      gruposMap[grupoId]!.add(
        CensoTitleEntity(
          id: id,
          nomeEtapa: nomeEtapa,
          tituloExibicao: titulo,
          valor: valor,
          isProfessores: nomeEtapa.endsWith('P'),
          grupoId: grupoId,
          percentualPopulacao: indice['percentual_populacao'] != null
              ? _toDouble(indice['percentual_populacao'])
              : null,
        ),
      );
    }

    final grupos = gruposMap.entries
        .map(
          (entry) => CensoGroupEntity(
            id: entry.key,
            nome: grupoNomes[entry.key] ?? '',
            titulos: entry.value,
          ),
        )
        .toList();

    return CensoEscolarEntity(
      cidadeId: _toInt(cityData['id'] ?? cityData['idCidades']),
      cidadeNome:
          (cityData['nome'] ?? cityData['nome_cidade'] ?? '').toString(),
      censoAno: _toInt(cityData['censo_ano']) == 0
          ? null
          : _toInt(cityData['censo_ano']),
      anoPopulacao: _toInt(cityData['ano_populacao']) == 0
          ? null
          : _toInt(cityData['ano_populacao']),
      grupos: grupos,
      valoresPorEtapa: valoresPorEtapa,
    );
  }

  CensoEscolarEntity _buildAggregatedCenso({
    required Map<String, double> censoAgregado,
    required List<Map<String, dynamic>> citiesData,
  }) {
    if (citiesData.isEmpty) {
      final grupos = <CensoGroupEntity>[
        CensoGroupEntity(
          id: 0,
          nome: 'Agregado',
          titulos: censoAgregado.entries
              .map(
                (e) => CensoTitleEntity(
                  id: 0,
                  nomeEtapa: e.key,
                  tituloExibicao: e.key,
                  valor: e.value,
                  isProfessores: e.key.endsWith('P'),
                  grupoId: 0,
                ),
              )
              .toList(),
        ),
      ];

      return CensoEscolarEntity(
        cidadeId: 0,
        cidadeNome: 'Agregado',
        anoPopulacao: null,
        grupos: grupos,
        valoresPorEtapa: censoAgregado,
      );
    }

    final gruposMap = <int, List<CensoTitleEntity>>{};
    final grupoNomes = <int, String>{};

    for (final cityData in citiesData) {
      final indices = _extractIndicesFromCityData(cityData);
      for (final indice in indices) {
        final nomeEtapa = indice['nome_etapa'].toString();
        final titulo = indice['titulo'].toString();
        final group = indice['grupo'] as Map<String, dynamic>? ?? const {};
        final grupoId = _toInt(group['id']);
        final grupoNome = (group['nome'] ?? '').toString();
        final id = _toInt(indice['id']);
        final valorAgregado = censoAgregado[nomeEtapa] ?? 0.0;

        grupoNomes[grupoId] = grupoNome;
        gruposMap.putIfAbsent(grupoId, () => []);

        final jaExiste =
            gruposMap[grupoId]!.any((titulo) => titulo.nomeEtapa == nomeEtapa);
        if (jaExiste) continue;

        gruposMap[grupoId]!.add(
          CensoTitleEntity(
            id: id,
            nomeEtapa: nomeEtapa,
            tituloExibicao: titulo,
            valor: valorAgregado,
            isProfessores: nomeEtapa.endsWith('P'),
            grupoId: grupoId,
            percentualPopulacao: indice['percentual_populacao'] != null
                ? _toDouble(indice['percentual_populacao'])
                : null,
          ),
        );
      }
    }

    final grupos = gruposMap.entries
        .map(
          (entry) => CensoGroupEntity(
            id: entry.key,
            nome: grupoNomes[entry.key] ?? 'Agregado',
            titulos: entry.value,
          ),
        )
        .toList();

    return CensoEscolarEntity(
      cidadeId: 0,
      cidadeNome: 'Agregado',
      anoPopulacao: null,
      grupos: grupos,
      valoresPorEtapa: censoAgregado,
    );
  }

  List<Map<String, dynamic>> _buildIndicesFromCenso(CensoEscolarEntity censo) {
    final indices = <Map<String, dynamic>>[];
    for (final grupo in censo.grupos) {
      for (final titulo in grupo.titulos) {
        indices.add({
          'id': titulo.id,
          'nome_etapa': titulo.nomeEtapa,
          'titulo': titulo.tituloExibicao,
          'valor': titulo.valor,
          'grupo': {
            'id': grupo.id,
            'nome': grupo.nome,
          },
        });
      }
    }
    return indices;
  }

  List<Map<String, dynamic>> _buildIndicadoresFromIndices(
    List<Map<String, dynamic>> indices,
  ) {
    return indices.map((item) {
      final grupo = item['grupo'] as Map<String, dynamic>? ?? const {};
      return <String, dynamic>{
        'id': item['id'],
        'nome': item['nome_etapa'],
        'titulo': item['titulo'],
        'valor': item['valor'],
        'grupo_id': _toInt(grupo['id']),
        'grupo_nome': (grupo['nome'] ?? '').toString(),
      };
    }).toList();
  }

  List<Map<String, dynamic>> _buildLegacyIndicesFromIndices(
    List<Map<String, dynamic>> indices,
    int cidadeId,
  ) {
    return indices.map((item) {
      final grupo = item['grupo'] as Map<String, dynamic>? ?? const {};
      final grupoId = _toInt(grupo['id']);
      final grupoNome = (grupo['nome'] ?? '').toString();

      return <String, dynamic>{
        'idindice_etapa': _toInt(item['id']),
        'nome_etapa': item['nome_etapa'],
        'titulo_etapa': item['titulo'],
        'grupos_grupo_id': grupoId,
        'grupo': {
          'grupo_id': grupoId,
          'nome_grupo': grupoNome,
        },
        'pivot': {
          'cidades_idCidades': cidadeId,
          'indice_etapa_idindice_etapa': _toInt(item['id']),
          'etapa_valor': _toDouble(item['valor']),
        },
      };
    }).toList();
  }

  Map<String, double> _calculateAggregatedCensoFromCities(
    List<Map<String, dynamic>> citiesData,
    Map<String, double> fallback,
  ) {
    final aggregated = <String, double>{};

    for (final city in citiesData) {
      final indices = _extractIndicesFromCityData(city);
      for (final indice in indices) {
        final nomeEtapa = indice['nome_etapa'].toString();
        if (nomeEtapa.isEmpty) continue;
        aggregated[nomeEtapa] =
            (aggregated[nomeEtapa] ?? 0) + _toDouble(indice['valor']);
      }
    }

    if (aggregated.isNotEmpty) return aggregated;
    return Map<String, double>.from(fallback);
  }
}
