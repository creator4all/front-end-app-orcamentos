import 'package:mobx/mobx.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/indicator_group_entity.dart';
import '../../domain/entities/product_config_entity.dart';
import '../../domain/entities/subcategory_entity.dart';
import '../../domain/repositories/product_config_repository.dart';

part 'product_management_store.g.dart';

/// Store MobX para gerenciamento de produtos
class ProductManagementStore = _ProductManagementStoreBase
    with _$ProductManagementStore;

/// Enum para o nível de navegação atual
enum NavigationLevel { categories, subcategories, products }

abstract class _ProductManagementStoreBase with Store {
  final ProductConfigRepository repository;

  _ProductManagementStoreBase({
    required this.repository,
  });

  // ============ Observable State ============

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  NavigationLevel currentLevel = NavigationLevel.categories;

  @observable
  ObservableList<CategoryEntity> categories = ObservableList<CategoryEntity>();

  @observable
  ObservableList<SubcategoryEntity> subcategories =
      ObservableList<SubcategoryEntity>();

  @observable
  ObservableList<ProductConfigEntity> products =
      ObservableList<ProductConfigEntity>();

  @observable
  CategoryEntity? selectedCategory;

  @observable
  SubcategoryEntity? selectedSubcategory;

  @observable
  ProductConfigEntity? selectedProduct;

  @observable
  ObservableList<IndicatorGroupEntity> indicatorGroups =
      ObservableList<IndicatorGroupEntity>();

  @observable
  bool isSaving = false;

  @observable
  bool isLoadingProductDetails = false;

  // ============ Computed ============

  @computed
  String get pageTitle {
    switch (currentLevel) {
      case NavigationLevel.categories:
        return 'Configurar Produtos';
      case NavigationLevel.subcategories:
        return selectedCategory?.nome ?? 'Subcategorias';
      case NavigationLevel.products:
        return selectedSubcategory?.nome ?? 'Produtos';
    }
  }

  @computed
  bool get canGoBack => currentLevel != NavigationLevel.categories;

  // ============ Actions ============

  @action
  Future<void> loadCategories() async {
    isLoading = true;
    errorMessage = null;

    final result = await repository.getCategories();

    result.fold(
      (failure) => errorMessage = failure.message,
      (data) {
        categories.clear();
        categories.addAll(data);
        currentLevel = NavigationLevel.categories;
      },
    );

    isLoading = false;
  }

  @action
  Future<void> selectCategory(CategoryEntity category) async {
    selectedCategory = category;
    isLoading = true;
    errorMessage = null;

    final result = await repository.getSubcategories(category.id);

    result.fold(
      (failure) => errorMessage = failure.message,
      (data) {
        subcategories.clear();
        subcategories.addAll(data);
        currentLevel = NavigationLevel.subcategories;
      },
    );

    isLoading = false;
  }

  @action
  Future<void> selectSubcategory(SubcategoryEntity subcategory) async {
    selectedSubcategory = subcategory;
    isLoading = true;
    errorMessage = null;

    final result = await repository.getProducts(subcategory.id);

    result.fold(
      (failure) => errorMessage = failure.message,
      (data) {
        products.clear();
        products.addAll(data);
        currentLevel = NavigationLevel.products;
      },
    );

    isLoading = false;
  }

  @action
  Future<void> loadProductDetails(int productId) async {
    isLoadingProductDetails = true;
    errorMessage = null;

    final result = await repository.getProductDetails(productId);

    result.fold(
      (failure) => errorMessage = failure.message,
      (data) => selectedProduct = data,
    );

    isLoadingProductDetails = false;
  }

  @action
  Future<void> loadIndicators() async {
    if (indicatorGroups.isNotEmpty) return;

    final result = await repository.getIndicators();

    result.fold(
      (failure) => errorMessage = failure.message,
      (data) {
        indicatorGroups.clear();
        indicatorGroups.addAll(data);
      },
    );
  }

  @action
  Future<bool> updateProduct(ProductConfigEntity product) async {
    isSaving = true;
    errorMessage = null;

    final result = await repository.updateProduct(product);

    bool success = false;
    result.fold(
      (failure) => errorMessage = failure.message,
      (data) {
        // Atualiza o produto na lista
        final index = products.indexWhere((p) => p.id == data.id);
        if (index != -1) {
          products[index] = data;
        }
        selectedProduct = null;
        success = true;
      },
    );

    isSaving = false;
    return success;
  }

  @action
  void goBack() {
    switch (currentLevel) {
      case NavigationLevel.subcategories:
        currentLevel = NavigationLevel.categories;
        selectedCategory = null;
        subcategories.clear();
        break;
      case NavigationLevel.products:
        currentLevel = NavigationLevel.subcategories;
        selectedSubcategory = null;
        products.clear();
        break;
      case NavigationLevel.categories:
        // Já está no primeiro nível
        break;
    }
  }

  @action
  void clearSelectedProduct() {
    selectedProduct = null;
  }

  @action
  void clearError() {
    errorMessage = null;
  }

  @action
  Future<bool> updateProductStatus(int productId, bool status) async {
    isSaving = true;
    errorMessage = null;

    final result = await repository.updateProductStatus(productId, status);

    bool success = false;
    result.fold(
      (failure) => errorMessage = failure.message,
      (_) {
        // Atualiza o produto na lista local (status = pro_status)
        final index = products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          products[index] = products[index].copyWith(status: status);
        }
        success = true;
      },
    );

    isSaving = false;
    return success;
  }
}
