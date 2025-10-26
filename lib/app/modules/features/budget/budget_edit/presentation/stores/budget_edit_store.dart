import 'package:dartz/dartz.dart';
import 'package:mobx/mobx.dart';

import '../../../budget_config/data/models/category_dto.dart';
import '../../../budget_config/domain/entities/category_entity.dart';
import '../../../budget_config/domain/entities/census_data_entity.dart';
import '../../../budget_config/domain/entities/product_entity.dart';
import '../../../budget_config/domain/entities/subcategory_entity.dart';
import '../../../budget_config/domain/usecases/get_census_data_usecase.dart';
import '../../../shared/errors/budget_failure.dart';
import '../../domain/entities/budget_edit_entity.dart';
import '../../domain/usecases/get_all_budget_products_for_edit_usecase.dart';
import '../../domain/usecases/get_budget_for_edit_usecase.dart';
import '../../domain/usecases/update_budget_usecase.dart';

part 'budget_edit_store.g.dart';

class BudgetEditStore = _BudgetEditStoreBase with _$BudgetEditStore;

abstract class _BudgetEditStoreBase with Store {
  final GetBudgetForEditUseCase getBudgetForEditUseCase;
  final UpdateBudgetUseCase updateBudgetUseCase;
  final GetCensusDataUseCase getCensusDataUseCase;
  final GetAllBudgetProductsForEditUseCase getAllProductsUseCase;

  _BudgetEditStoreBase({
    required this.getBudgetForEditUseCase,
    required this.updateBudgetUseCase,
    required this.getCensusDataUseCase,
    required this.getAllProductsUseCase,
  });

  // ========== OBSERVABLES ==========

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

  // ========== COMPUTED ==========

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
    // 🔧 FIX: Usar cálculo hierárquico igual ao budget_config
    // Produtos estão em categories -> subcategorias -> produtos
    // NÃO usar budgetData.products (está vazio!)
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
  bool get hasCategories => categories.isNotEmpty;

  @computed
  bool get hasCensusData => censusData != null && censusData!.hasData;

  @computed
  bool get isFullyLoaded => !isLoading && !isLoadingProducts;

  // ========== ACTIONS ==========

  @action
  Future<void> initialize(int budgetId) async {
    print('🔄 [BudgetEditStore] Inicializando edição do orçamento: $budgetId');

    // 1. Carregar estrutura (categorias/subcategorias com estatísticas)
    await loadBudgetForEdit(budgetId);

    // 2. Carregar TODOS os produtos com estados reais do banco
    await _loadAllProducts(budgetId);

    // 3. Carregar censo se tiver cidade
    if (budgetData != null && budgetData!.cityIds.isNotEmpty) {
      await loadCensusData(budgetData!.cityIds.first);
    }
  }

  @action
  Future<void> loadBudgetForEdit(int budgetId) async {
    isLoading = true;
    isLoadingProducts = true;
    error = null;

    try {
      print('🔄 [BudgetEditStore] Carregando orçamento para edição: $budgetId');

      final result = await getBudgetForEditUseCase(budgetId);

      result.fold(
        (failure) {
          print('❌ [BudgetEditStore] Erro: ${failure.message}');
          error = failure.message;
          budgetData = null;
          isLoading = false;
          isLoadingProducts = false;
        },
        (budget) {
          print('✅ [BudgetEditStore] Orçamento carregado');
          budgetData = budget;

          // Inicializar categorias a partir dos dados do orçamento
          categories.clear();
          categories.addAll(_parseCategoriesFromBudget(budget));

          print(
              '📦 [BudgetEditStore] Categorias carregadas: ${categories.length}');

          // Inicializar estados
          selectedStatus = budget.status;
          isArchived = budget.isArchived;
          validityDate = budget.validityDate;
          budgetName = budget.name;

          // Inicializar produtos selecionados
          selectedProductIds.clear();
          selectedProductIds.addAll(
            budget.products.where((p) => p.isSelected).map((p) => p.productId),
          );

          print('   Produtos selecionados: ${selectedProductIds.length}');

          isLoading = false;
          isLoadingProducts = false;
        },
      );
    } catch (e) {
      print('❌ [BudgetEditStore] Erro inesperado: $e');
      error = 'Erro ao carregar orçamento: $e';
      isLoading = false;
      isLoadingProducts = false;
    }
  }

  /// Carrega TODOS os produtos do orçamento com estados reais do banco
  /// e faz merge com a estrutura de categorias/subcategorias
  @action
  Future<void> _loadAllProducts(int budgetId) async {
    isLoadingProducts = true;

    try {
      print('🌐 [BudgetEditStore] Buscando todos os produtos...');

      final result = await getAllProductsUseCase(budgetId: budgetId);

      result.fold(
        (failure) {
          print(
              '❌ [BudgetEditStore] Erro ao carregar produtos: ${failure.message}');
          error = failure.message;
          isLoadingProducts = false;
        },
        (allProducts) {
          print(
              '✅ [BudgetEditStore] ${allProducts.length} produtos carregados');

          // Agrupar produtos por subcategoria_id
          final productsBySubcategory = <int, List<ProductEntity>>{};

          for (final product in allProducts) {
            final subId = product.subcategoriaId;
            productsBySubcategory.putIfAbsent(subId, () => []);
            productsBySubcategory[subId]!.add(product);
          }

          print('📦 [BudgetEditStore] Produtos agrupados por subcategoria:');
          productsBySubcategory.forEach((subId, prods) {
            print('   - Subcategoria $subId: ${prods.length} produtos');
          });

          // Distribuir produtos nas subcategorias corretas
          final updatedCategories = categories.map((cat) {
            // Atualizar subcategorias com produtos reais
            final updatedSubcategories = cat.subcategorias.map((sub) {
              final subProducts = productsBySubcategory[sub.id] ?? [];

              if (subProducts.isEmpty) {
                // Subcategoria sem produtos, manter como está (com estatísticas)
                return sub;
              }

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

          print('✅ [BudgetEditStore] Produtos distribuídos nas categorias');

          // Atualizar selectedProductIds baseado nos produtos reais
          _updateSelectedProductIds();

          print('💰 Total calculado: R\$ ${totalValue.toStringAsFixed(2)}');
          print('📦 Produtos selecionados: $selectedProductsCount');

          isLoadingProducts = false;
        },
      );
    } catch (e) {
      print('❌ [BudgetEditStore] Erro inesperado ao carregar produtos: $e');
      error = 'Erro ao carregar produtos: $e';
      isLoadingProducts = false;
    }
  }

  /// Atualiza o set de produtos selecionados baseado no estado real dos produtos
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

    print(
        '✅ [BudgetEditStore] Produtos selecionados atualizados: ${selectedProductIds.length}');
  }

  /// Converte dados do orçamento em estrutura de categorias (apenas estrutura, sem produtos)
  List<CategoryEntity> _parseCategoriesFromBudget(BudgetEditEntity budget) {
    print('🔄 [BudgetEditStore] Parseando estrutura de categorias...');

    try {
      // Verificar se categoriesData contém uma lista de categorias
      if (budget.categoriesData is! List) {
        print('❌ [BudgetEditStore] categoriesData não é uma lista');
        print('   Tipo: ${budget.categoriesData.runtimeType}');
        print('   Conteúdo: ${budget.categoriesData}');
        return [];
      }

      final categoriesList = budget.categoriesData as List<dynamic>;
      print(
          '📦 [BudgetEditStore] ${categoriesList.length} categorias encontradas');

      final List<CategoryEntity> categories = [];

      for (var i = 0; i < categoriesList.length; i++) {
        try {
          final categoryJson = categoriesList[i] as Map<String, dynamic>;
          print(
              '   Parseando categoria ${i + 1}/${categoriesList.length}: ${categoryJson['nome']}');

          // Usar CategoryDTO para parsing (estrutura + estatísticas)
          final categoryDto = CategoryDTO.fromJson(categoryJson);
          final categoryEntity = categoryDto.toEntity();

          // Adicionar categoria (produtos virão depois em _loadAllProducts)
          categories.add(categoryEntity);
          print('   ✅ Categoria ${categoryEntity.nome} parseada com sucesso');
        } catch (e, stackTrace) {
          print('   ❌ Erro ao parsear categoria ${i + 1}: $e');
          print('   Stack: $stackTrace');
          // Continua parseando outras categorias
        }
      }

      print(
          '✅ [BudgetEditStore] ${categories.length} categorias (estrutura) parseadas com sucesso');
      return categories;
    } catch (e, stackTrace) {
      print('❌ [BudgetEditStore] Erro geral ao parsear categorias: $e');
      print('Stack: $stackTrace');
      return [];
    }
  }

  @action
  Future<void> loadCensusData(int cityId) async {
    isLoadingCensus = true;

    try {
      print(
          '🔄 [BudgetEditStore] Carregando dados do censo para cidade: $cityId');

      final result = await getCensusDataUseCase(cityId);

      result.fold(
        (failure) {
          print(
              '❌ [BudgetEditStore] Erro ao carregar censo: ${failure.message}');
          error = failure.message;
        },
        (data) {
          print('✅ [BudgetEditStore] Dados do censo carregados');
          censusData = data;
        },
      );
    } catch (e) {
      print('❌ [BudgetEditStore] Erro inesperado ao carregar censo: $e');
    } finally {
      isLoadingCensus = false;
    }
  }

  @action
  void toggleCategory(int categoryId) {
    final categoryIndex = categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex != -1) {
      // A CategoryEntity não tem isExpanded
      // A lógica de expansão será gerenciada pela UI
      print('🔄 [BudgetEditStore] Categoria selecionada: $categoryId');
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

    print(
        '🔄 [BudgetEditStore] Produto $productId ${selected ? "selecionado" : "desmarcado"}');
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

    final products = budgetData!.products
        .where((p) => p.category.contains(subcategoryId.toString()));

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
  }

  @action
  Future<Either<BudgetFailure, BudgetEditEntity>> updateBudget() async {
    if (budgetData == null) {
      error = 'Orçamento não carregado';
      return const Left(ValidationFailure('Orçamento não carregado'));
    }

    isSaving = true;
    error = null;

    try {
      print('🔄 [BudgetEditStore] Salvando alterações...');

      // Calcular dias de validade
      int? validityDays;
      if (validityDate != null) {
        final hoje = DateTime.now();
        final hojeDate = DateTime(hoje.year, hoje.month, hoje.day);
        validityDays = validityDate!.difference(hojeDate).inDays;
      }

      final result = await updateBudgetUseCase(
        budgetId: budgetData!.id,
        validityDays: validityDays,
        validityDate: validityDate,
        status: selectedStatus,
        isArchived: isArchived,
        selectedProductIds: selectedProductIds.toList(),
      );

      return result.fold(
        (failure) {
          print('❌ [BudgetEditStore] Erro ao salvar: ${failure.message}');
          error = failure.message;
          isSaving = false;
          return Left(failure);
        },
        (updatedBudget) {
          print('✅ [BudgetEditStore] Orçamento salvo com sucesso');
          budgetData = updatedBudget;
          isSaving = false;
          return Right(updatedBudget);
        },
      );
    } catch (e) {
      print('❌ [BudgetEditStore] Erro inesperado: $e');
      error = 'Erro ao salvar: $e';
      isSaving = false;
      return Left(UnknownFailure(e.toString()));
    }
  }

  @action
  Future<Either<BudgetFailure, BudgetEditEntity>> saveBudget() async {
    // Alias para updateBudget para manter compatibilidade
    return updateBudget();
  }

  @action
  void reset() {
    budgetData = null;
    selectedProductIds.clear();
    categories.clear();
    selectedCategory = null;
    selectedSubcategory = null;
    censusData = null;
    selectedStatus = 'pendente';
    isArchived = false;
    validityDate = null;
    budgetName = null;
    error = null;
    isLoading = false;
    isSaving = false;
    isLoadingProducts = false;
    isLoadingCensus = false;
  }

  // ========== MÉTODOS PARA MODALS ==========

  @action
  void toggleCategoryWithCascade(int categoryId, bool selected) {
    print('🔄 [BudgetEditStore] Toggle categoria $categoryId: $selected');

    final categoryIndex = categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex == -1) return;

    final category = categories[categoryIndex];

    // Atualizar categoria
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

    // Atualizar produtos selecionados
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
  }

  @action
  void toggleSubcategoryWithCascade(
      int categoryId, int subcategoryId, bool selected) {
    print(
        '🔄 [BudgetEditStore] Toggle subcategoria $subcategoryId na categoria $categoryId: $selected');

    final categoryIndex = categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex == -1) return;

    final category = categories[categoryIndex];
    final subIndex =
        category.subcategorias.indexWhere((s) => s.id == subcategoryId);
    if (subIndex == -1) return;

    final subcategory = category.subcategorias[subIndex];

    // Atualizar subcategoria
    final updatedSubcategory = subcategory.copyWith(
      produtos: subcategory.produtos.map((prod) {
        return prod.copyWith(selecionado: selected);
      }).toList(),
    );

    // Atualizar categoria com subcategoria modificada
    final updatedSubcategories =
        List<SubcategoryEntity>.from(category.subcategorias);
    updatedSubcategories[subIndex] = updatedSubcategory;

    final updatedCategory = category.copyWith(
      subcategorias: updatedSubcategories,
    );

    categories[categoryIndex] = updatedCategory;

    // Atualizar produtos selecionados
    if (selected) {
      for (final prod in updatedSubcategory.produtos) {
        selectedProductIds.add(prod.id);
      }
    } else {
      for (final prod in updatedSubcategory.produtos) {
        selectedProductIds.remove(prod.id);
      }
    }
  }

  @action
  void toggleProduct(int productId, bool selected) {
    print('🔄 [BudgetEditStore] Toggle produto $productId: $selected');

    // Encontrar e atualizar o produto em sua categoria/subcategoria
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];
        final prodIndex =
            subcategory.produtos.indexWhere((p) => p.id == productId);

        if (prodIndex != -1) {
          final product = subcategory.produtos[prodIndex];
          final updatedProduct = product.copyWith(selecionado: selected);

          // Atualizar lista de produtos (com tipo explícito)
          final updatedProducts =
              List<ProductEntity>.from(subcategory.produtos);
          updatedProducts[prodIndex] = updatedProduct;

          // Atualizar subcategoria
          final updatedSubcategory =
              subcategory.copyWith(produtos: updatedProducts);

          // Atualizar categoria
          final updatedSubcategories =
              List<SubcategoryEntity>.from(category.subcategorias);
          updatedSubcategories[j] = updatedSubcategory;

          final updatedCategory =
              category.copyWith(subcategorias: updatedSubcategories);

          categories[i] = updatedCategory;

          // Atualizar set de produtos selecionados
          if (selected) {
            selectedProductIds.add(productId);
          } else {
            selectedProductIds.remove(productId);
          }

          return;
        }
      }
    }
  }

  @action
  void updateProductQuantity(int productId, int quantity) {
    print(
        '🔄 [BudgetEditStore] Atualizando quantidade do produto $productId: $quantity');

    // Encontrar e atualizar o produto
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];
        final prodIndex =
            subcategory.produtos.indexWhere((p) => p.id == productId);

        if (prodIndex != -1) {
          final product = subcategory.produtos[prodIndex];
          final updatedProduct = product.copyWith(quantidade: quantity);

          // Atualizar lista de produtos (com tipo explícito)
          final updatedProducts =
              List<ProductEntity>.from(subcategory.produtos);
          updatedProducts[prodIndex] = updatedProduct;

          // Atualizar subcategoria
          final updatedSubcategory =
              subcategory.copyWith(produtos: updatedProducts);

          // Atualizar categoria
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
  void updateProductObservations(int productId, String observations) {
    print('🔄 [BudgetEditStore] Atualizando observações do produto $productId');

    // Encontrar e atualizar o produto
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];
        final prodIndex =
            subcategory.produtos.indexWhere((p) => p.id == productId);

        if (prodIndex != -1) {
          final product = subcategory.produtos[prodIndex];
          final updatedProduct = product.copyWith(observacoes: observations);

          // Atualizar lista de produtos (com tipo explícito)
          final updatedProducts =
              List<ProductEntity>.from(subcategory.produtos);
          updatedProducts[prodIndex] = updatedProduct;

          // Atualizar subcategoria
          final updatedSubcategory =
              subcategory.copyWith(produtos: updatedProducts);

          // Atualizar categoria
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
}
