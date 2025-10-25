import 'package:dartz/dartz.dart';
import 'package:mobx/mobx.dart';

import '../../../shared/errors/budget_failure.dart';
import '../../domain/entities/budget_detail_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/census_data_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/subcategory_entity.dart';
import '../../domain/usecases/calculate_totals_usecase.dart';
import '../../domain/usecases/finalize_budget_usecase.dart';
import '../../domain/usecases/get_budget_detail_usecase.dart';
import '../../domain/usecases/get_census_data_usecase.dart';
import '../../domain/usecases/toggle_category_usecase.dart';

part 'budget_config_store.g.dart';

class BudgetConfigStore = _BudgetConfigStoreBase with _$BudgetConfigStore;

abstract class _BudgetConfigStoreBase with Store {
  final GetBudgetDetailUseCase getBudgetDetailUseCase;
  final GetCensusDataUseCase getCensusDataUseCase;
  final ToggleCategoryUseCase toggleCategoryUseCase;
  final CalculateTotalsUseCase calculateTotalsUseCase;
  final FinalizeBudgetUseCase finalizeBudgetUseCase;

  _BudgetConfigStoreBase({
    required this.getBudgetDetailUseCase,
    required this.getCensusDataUseCase,
    required this.toggleCategoryUseCase,
    required this.calculateTotalsUseCase,
    required this.finalizeBudgetUseCase,
  });

  // ========== OBSERVABLES ==========

  @observable
  bool isLoading = false;

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

  @computed
  bool get hasData => budgetDetail != null;

  @computed
  bool get hasCensusData => censusData != null && censusData!.hasData;

  // ✅ Novo computed para verificar se tem categorias
  @computed
  bool get hasCategories => categories.isNotEmpty;

  // ========== ACTIONS ==========

  @action
  Future<void> initialize(int budgetId) async {
    print('🔄 [BudgetConfigStore] Inicializando com orçamento ID: $budgetId');

    await loadBudgetDetail(budgetId);

    // Carregar censo se tiver cidade
    if (budgetDetail != null && budgetDetail!.cityIds.isNotEmpty) {
      await loadCensusData(budgetDetail!.cityIds.first);
    }
  }

  @action
  Future<void> loadBudgetDetail(int budgetId) async {
    isLoading = true;
    error = null;

    try {
      print('🔄 [BudgetConfigStore] Carregando detalhes do orçamento...');

      final result = await getBudgetDetailUseCase(budgetId);

      result.fold(
        (failure) {
          print('❌ [BudgetConfigStore] Erro: ${failure.message}');
          error = failure.message;
          budgetDetail = null;
        },
        (budget) {
          print('✅ [BudgetConfigStore] Orçamento carregado: ${budget.id}');
          print(
              '📦 [BudgetConfigStore] Categorias recebidas: ${budget.categories.length}');

          budgetDetail = budget;

          // ✅ Inicializar categorias
          categories.clear();
          categories.addAll(budget.categories);

          print(
              '📊 [BudgetConfigStore] Categorias na store: ${categories.length}');
          for (var cat in categories) {
            print(
                '   - ${cat.nome}: ${cat.subcategorias.length} subcategorias, ${cat.totalActiveProducts} produtos');
          }

          // Inicializar estados de categorias (manter para compatibilidade)
          categoryStates.clear();
          categoryStates.addAll(budget.categoryStates);

          // Inicializar data de validade
          validityDate = budget.validityDate;

          // Inicializar nome
          budgetName = budget.name;
        },
      );
    } catch (e) {
      print('❌ [BudgetConfigStore] Erro inesperado: $e');
      error = 'Erro ao carregar orçamento: $e';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> loadCensusData(int cityId) async {
    isLoadingCensus = true;

    try {
      print('🔄 [BudgetConfigStore] Carregando censo da cidade: $cityId');

      final result = await getCensusDataUseCase(cityId);

      result.fold(
        (failure) {
          print(
              '❌ [BudgetConfigStore] Erro ao carregar censo: ${failure.message}');
          // Não definir error aqui pois censo é opcional
          censusData = null;
        },
        (census) {
          print('✅ [BudgetConfigStore] Censo carregado: ${census.summary}');
          censusData = census;
        },
      );
    } catch (e) {
      print('❌ [BudgetConfigStore] Erro inesperado ao carregar censo: $e');
      censusData = null;
    } finally {
      isLoadingCensus = false;
    }
  }

  @action
  void toggleCategory(String categoryKey) {
    print('🔄 [BudgetConfigStore] Alternando categoria: $categoryKey');

    final newValue = toggleCategoryUseCase(categoryKey, categoryStates);
    categoryStates[categoryKey] = newValue;

    print('✅ [BudgetConfigStore] Categoria $categoryKey = $newValue');
  }

  @action
  void setValidityDate(DateTime? date) {
    validityDate = date;
    print('📅 [BudgetConfigStore] Data de validade definida: $date');
  }

  @action
  void setBudgetName(String? name) {
    budgetName = name;
    print('📝 [BudgetConfigStore] Nome do orçamento definido: $name');
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
            print(
                '⚠️ [BudgetConfigStore] Produto $productId está inativo, ignorando toggle');
            return;
          }

          // ✅ Alternar campo 'selecionado'
          final updatedProduct = product.copyWith(selecionado: selected);

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

          print('✅ [BudgetConfigStore] Produto $productId agora: $selected');
          print('💰 Total recalculado: R\$ ${totalValue.toStringAsFixed(2)}');
          print('📦 Produtos selecionados: $totalSelectedProducts');
          return;
        }
      }
    }

    print('⚠️ [BudgetConfigStore] Produto $productId não encontrado');
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

  /// Toggle de categoria com desmarcação em cascata
  /// Se marcar (true): marca a categoria
  /// Se desmarcar (false): desmarca TODOS os produtos de TODAS as subcategorias
  @action
  void toggleCategoryWithCascade(int categoryId, bool selected) {
    print(
        '🔄 [BudgetConfigStore] Toggle categoria $categoryId com cascata: $selected');

    // Encontrar a categoria
    final categoryIndex = categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex == -1) {
      print('⚠️ [BudgetConfigStore] Categoria $categoryId não encontrada');
      return;
    }

    final category = categories[categoryIndex];

    if (!selected) {
      // ❌ DESMARCAR: desmarcar TODOS os produtos de TODAS as subcategorias
      print(
          '   ❌ Desmarcando todos os produtos da categoria: ${category.nome}');
      print(
          '   📊 ANTES - Produtos selecionados na categoria: ${category.selectedProductsCount}');
      print(
          '   📊 ANTES - hasSelectedProducts: ${category.hasSelectedProducts}');

      final updatedSubcategories = category.subcategorias.map((subcategory) {
        print('      🔍 Subcategoria: ${subcategory.nome}');
        print('         Produtos antes: ${subcategory.produtos.length}');
        print(
            '         Selecionados antes: ${subcategory.selectedProductsCount}');

        // Desmarcar todos os produtos desta subcategoria
        final updatedProducts = subcategory.produtos.map((product) {
          if (product.selecionado) {
            print(
                '         ❌ Desmarcando: ${product.solucao} (selecionado: ${product.selecionado})');
          }
          final newProduct =
              product.copyWith(selecionado: false, quantidade: 1);
          print(
              '         ✓ Resultado: ${newProduct.solucao} (selecionado: ${newProduct.selecionado})');
          return newProduct;
        }).toList();

        print('         Produtos depois: ${updatedProducts.length}');
        print(
            '         Selecionados na lista: ${updatedProducts.where((p) => p.selecionado).length}');

        // ⚠️ CRÍTICO: Zerar estatísticas para forçar recálculo via produtos
        // Quando desmarcamos produtos, estatísticas antigas causam estado inconsistente
        final estatisticasZeradas = subcategory.estatisticas?.copyWith(
          totalProdutos: 0,
          produtosSelecionados: 0,
          valorTotal: 0.0,
          valorSelecionado: 0.0,
        );

        // Atualizar subcategoria com produtos desmarcados E estatísticas zeradas
        final newSub = subcategory.copyWith(
          produtos: updatedProducts,
          estatisticas: estatisticasZeradas,
        );
        print(
            '         Selecionados no getter: ${newSub.selectedProductsCount}');
        return newSub;
      }).toList();

      // Criar nova categoria com subcategorias atualizadas (sem alterar estatísticas)
      final updatedCategory =
          category.copyWith(subcategorias: updatedSubcategories);

      print(
          '   📊 DEPOIS - Produtos selecionados na categoria: ${updatedCategory.selectedProductsCount}');
      print(
          '   📊 DEPOIS - hasSelectedProducts: ${updatedCategory.hasSelectedProducts}');

      // Atualizar na lista com reatribuição completa para forçar notificação MobX
      final newCategories = List<CategoryEntity>.from(categories);
      newCategories[categoryIndex] = updatedCategory;
      categories = ObservableList.of(newCategories);

      print('   ✅ Todos os produtos desmarcados');
      print('   💰 Total recalculado: R\$ ${totalValue.toStringAsFixed(2)}');
      print('   📦 Produtos selecionados: $totalSelectedProducts');
      print(
          '   🔍 hasSelectedProducts: ${updatedCategory.hasSelectedProducts}');
    } else {
      // ✅ MARCAR: apenas marca a categoria (não seleciona produtos automaticamente)
      print('   ✅ Categoria marcada: ${category.nome}');
      print(
          '   ℹ️ Produtos devem ser selecionados individualmente nas subcategorias');
      // Nenhuma ação necessária, produtos devem ser selecionados individualmente
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
}
