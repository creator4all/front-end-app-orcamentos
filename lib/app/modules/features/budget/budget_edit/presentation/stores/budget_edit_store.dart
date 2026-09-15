import 'package:dartz/dartz.dart';
import 'package:mobx/mobx.dart';

import '../../../../../../shared/utils/api_number_parser.dart';
import '../../../../auth/presentation/stores/auth_store.dart';
import '../../../budget_config/data/models/category_dto.dart';
import '../../../budget_config/domain/entities/budget_detail_entity.dart';
import '../../../budget_config/domain/entities/category_entity.dart';
import '../../../budget_config/domain/entities/censo_escolar_entity.dart';
import '../../../budget_config/domain/entities/census_data_entity.dart';
import '../../../budget_config/domain/entities/indicador_etapa_entity.dart';
import '../../../budget_config/domain/entities/product_entity.dart';
import '../../../budget_config/domain/entities/subcategory_entity.dart';
import '../../../budget_config/domain/services/budget_value_rules.dart';
import '../../../budget_config/domain/services/censo_escolar_mapper.dart';
import '../../../budget_config/domain/services/product_calculation_service.dart';
import '../../../budget_config/domain/services/product_quantity_rules.dart';
import '../../../budget_config/domain/usecases/get_census_data_usecase.dart';
import '../../../shared/errors/budget_failure.dart';
import '../../../shared/models/budget_update_dto.dart';
import '../../../shared/models/product_selection_update_dto.dart';
import '../../domain/entities/budget_edit_entity.dart';
import '../../domain/services/budget_versioning_decision.dart';
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
  final CensoEscolarMapper censoEscolarMapper;

  _BudgetEditStoreBase({
    required this.getBudgetForEditUseCase,
    required this.updateBudgetUseCase,
    required this.getCensusDataUseCase,
    required this.authStore,
    required this.calculationService,
    required this.censoEscolarMapper,
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

  /// Referência única do estado original dos produtos, usada por [hasChanges].
  Map<int, BudgetProductSnapshot> _originalProductSnapshots = {};

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
    if (selectedStatus != _originalStatus) return true;
    if (isArchived != _originalIsArchived) return true;
    if (validityDate != _originalValidityDate) return true;

    return _hasProductChanges;
  }

  /// Mudança de produto em relação ao estado original, usada só para indicar
  /// alteração pendente na tela. A decisão de versionar é da API.
  bool get _hasProductChanges {
    return BudgetVersioningDecision.hasProductChanges(
      selectedIds: selectedProductIds.toSet(),
      originalSelectedIds: _originalSelectedProductIds,
      current: BudgetVersioningDecision.snapshotsFromCategories(categories),
      original: _originalProductSnapshots,
    );
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
    _originalProductSnapshots = {};
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

          final updatedProduct = product.copyWith(
            valor: BudgetValueRules.clampUnitValue(value),
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
          return;
        }
      }
    }
  }

  @action
  void updateProductQuantity(int productId, double rawQuantity) {
    final quantity = ProductQuantityRules.clamp(rawQuantity);

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
  void setProductManualQuantity(int productId, double rawQuantity) {
    final quantity = ProductQuantityRules.clamp(rawQuantity);

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
    if (isSaving) {
      return const Left(ValidationFailure('Salvamento em andamento'));
    }

    if (budgetData == null) {
      error = 'Orçamento não carregado';
      return const Left(ValidationFailure('Orçamento não carregado'));
    }

    if (validityDate == null) {
      error = 'Data de validade não definida';
      return const Left(ValidationFailure('Data de validade obrigatória'));
    }

    // Sem cidades hidratadas não há como classificar o orçamento, e o
    // versionamento cairia no endpoint de cidade única sem `orc_cidade_id`.
    if (budgetData!.cityIds.isEmpty) {
      const failure = ValidationFailure(
        'O orçamento não possui cidades carregadas. Recarregue os dados antes de versionar.',
      );
      error = failure.message;
      return const Left(failure);
    }

    if (BudgetValueRules.exceedsMaxTotal(totalValue)) {
      const failure = ValidationFailure(BudgetValueRules.totalExceededMessage);
      error = failure.message;
      return const Left(failure);
    }

    isSaving = true;
    error = null;

    try {
      // Envia sempre o estado completo dos produtos: a API compara com o
      // orçamento persistido e decide se versiona, atualiza ou mantém.
      final produtosParaSalvar = <ProductSelectionUpdateDto>[
        for (final category in categories)
          for (final subcategory in category.subcategorias)
            for (final product in subcategory.produtos)
              ProductSelectionUpdateDto.fromEntity(product),
      ];

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
          isSaving = false;
          budgetData = updatedBudget;
          selectedStatus = updatedBudget.status;
          isArchived = updatedBudget.isArchived;
          validityDate = updatedBudget.validityDate;
          budgetName = updatedBudget.name;
          _originalValidityDays = updatedBudget.validityDays;
          _validityDateChanged = false;
          _snapshotOriginalState();
          return Right(updatedBudget);
        },
      );
    } catch (_) {
      error = budgetSaveErrorMessage;
      isSaving = false;
      return const Left(UnknownFailure(budgetSaveErrorMessage));
    }
  }

  void _snapshotOriginalState() {
    _originalSelectedProductIds = Set<int>.from(selectedProductIds);
    _originalStatus = selectedStatus;
    _originalIsArchived = isArchived;
    _originalValidityDate = validityDate;
    _originalProductSnapshots =
        BudgetVersioningDecision.snapshotsFromCategories(categories);
  }

  /// Incorpora ao estado original apenas as quantidades alteradas pelo
  /// recálculo do censo salvo. Edições pendentes do usuário (seleção, preço,
  /// indicador, modo manual, observação e quantidade manual) continuam sendo
  /// mudanças de produto e seguem no próximo salvamento.
  void _updateOriginalQuantitiesSnapshot(
    Map<int, BudgetProductSnapshot> beforeRecalc,
  ) {
    final afterRecalc =
        BudgetVersioningDecision.snapshotsFromCategories(categories);
    final updated = Map<int, BudgetProductSnapshot>.from(
      _originalProductSnapshots,
    );

    for (final entry in afterRecalc.entries) {
      final original = updated[entry.key];
      final before = beforeRecalc[entry.key];
      if (original == null || before == null) continue;
      if (before.quantidade == entry.value.quantidade) continue;

      updated[entry.key] = original.withQuantidade(entry.value.quantidade);
    }

    _originalProductSnapshots = updated;
  }

  void _parseCensoEscolarFromCitiesData() {
    if (budgetData == null) {
      censoEscolar = null;
      return;
    }

    if (budgetData!.censoAgregado.isNotEmpty) {
      censoEscolar = censoEscolarMapper.buildAggregatedCenso(
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
      censoEscolar = censoEscolarMapper.buildCensoFromCityData(cityData);
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
        final cityId =
            ApiNumberParser.toInt(cityData['idCidades'] ?? cityData['id']);
        if (cityId == updatedCenso.cidadeId && updatedCenso.cidadeId > 0) {
          cityUpdated = true;
          return censoEscolarMapper.updateCityDataWithCenso(
              cityData, updatedCenso);
        }
        return cityData;
      }).toList();

      if (!cityUpdated && updatedCenso.cidadeId > 0) {
        updatedCitiesData.add(
          censoEscolarMapper
              .updateCityDataWithCenso(<String, dynamic>{}, updatedCenso),
        );
      }

      final updatedCensoAgregado =
          censoEscolarMapper.calculateAggregatedCensoFromCities(
        updatedCitiesData,
        budgetData!.censoAgregado,
      );

      budgetData = budgetData!.copyWith(
        citiesDataRaw: updatedCitiesData,
        censoAgregado: updatedCensoAgregado,
      );

      // Em multi-cidade a tela de censo devolve só a cidade editada; o
      // orçamento continua calculando com o censo agregado de todas as cidades.
      if (budgetData!.isMultiCity) {
        censoEscolar = censoEscolarMapper.buildAggregatedCenso(
          censoAgregado: updatedCensoAgregado,
          citiesData: updatedCitiesData,
        );
      }
    } else if (budgetData != null && updatedCenso.cidadeId > 0) {
      final newCityData = censoEscolarMapper
          .updateCityDataWithCenso(<String, dynamic>{}, updatedCenso);
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
    final beforeRecalc =
        BudgetVersioningDecision.snapshotsFromCategories(categories);
    _recalculateProductQuantities();
    _updateOriginalQuantitiesSnapshot(beforeRecalc);
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
}
