import 'package:dartz/dartz.dart';
import 'package:mobx/mobx.dart';

import '../../../../auth/presentation/stores/auth_store.dart';
import '../../../budget_config/data/models/category_dto.dart';
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
import '../../../budget_create/data/models/cidade_dto.dart';
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

  /// Censo escolar para edição (usado pelo SchoolCensusCard)
  @observable
  CensoEscolarEntity? censoEscolar;

  /// Produtos que passaram a ter disponibilidade após mudança no censo
  @observable
  ObservableList<ProductEntity> productsNeedingRemark =
      ObservableList<ProductEntity>();

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
  bool get hasCategories => categories.isNotEmpty;

  @computed
  bool get hasCensusData => censusData != null && censusData!.hasData;

  @computed
  bool get isFullyLoaded => !isLoading && !isLoadingProducts;

  // ========== ACTIONS ==========

  @action
  Future<void> initialize(int budgetId) async {
    // Carrega estrutura completa (categorias, subcategorias, produtos)
    // Produtos já vêm completos na resposta de GET /api/orcamentos/{id}
    await loadBudgetForEdit(budgetId);
  }

  @action
  Future<void> loadBudgetForEdit(int budgetId) async {
    isLoading = true;
    isLoadingProducts = true;
    error = null;

    try {
      final result = await getBudgetForEditUseCase(budgetId);

      result.fold(
        (failure) {
          error = failure.message;
          budgetData = null;
          isLoading = false;
          isLoadingProducts = false;
        },
        (budget) {
          budgetData = budget;

          // Inicializar categorias a partir dos dados do orçamento
          categories.clear();
          categories.addAll(_parseCategoriesFromBudget(budget));

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

          // Parsear censo escolar a partir dos dados da cidade
          _parseCensoEscolarFromCitiesData();

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
  }

  /// Converte dados do orçamento em estrutura de categorias (apenas estrutura, sem produtos)
  List<CategoryEntity> _parseCategoriesFromBudget(BudgetEditEntity budget) {
    try {
      // Verificar se categoriesData contém uma lista de categorias
      if (budget.categoriesData is! List) {
        return [];
      }

      final categoriesList = budget.categoriesData as List<dynamic>;

      final List<CategoryEntity> categories = [];

      for (var i = 0; i < categoriesList.length; i++) {
        try {
          final categoryJson = categoriesList[i] as Map<String, dynamic>;

          // Usar CategoryDTO para parsing (estrutura + estatísticas)
          final categoryDto = CategoryDTO.fromJson(categoryJson);
          final categoryEntity = categoryDto.toEntity();

          // Adicionar categoria (produtos virão depois em _loadAllProducts)
          categories.add(categoryEntity);
        } catch (e) {
          // Continua parseando outras categorias
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
    } catch (e) {
      // Erro silencioso
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
      error = 'Erro ao salvar: $e';
      isSaving = false;
      return Left(UnknownFailure(e.toString()));
    }
  }

  @action
  Future<Either<BudgetFailure, BudgetEditEntity>> saveBudget() async {
    // Usar sempre o método completo com DTO
    return saveBudgetWithDto();
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

    // Atualizar subcategoria
    final updatedSubcategory = subcategory.copyWith(
      produtos: subcategory.produtos.map((prod) {
        return prod.copyWith(selecionado: selected);
      }).toList(),
    );

    // Atualizar categoria com subcategoria modificada
    final updatedSubcategories = List<SubcategoryEntity>.from(
      category.subcategorias,
    );
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
    // Encontrar e atualizar o produto em sua categoria/subcategoria
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

          // 🧮 Recalcular quantidade baseado no censo quando selecionado
          if (selected && censoEscolar != null) {
            final novaQuantidade = calculationService.calcularQuantidade(
              updatedProduct,
              censoEscolar,
            );
            updatedProduct = updatedProduct.copyWith(
              quantidade: novaQuantidade.round(),
            );
          }

          // Atualizar lista de produtos (com tipo explícito)
          final updatedProducts = List<ProductEntity>.from(
            subcategory.produtos,
          );
          updatedProducts[prodIndex] = updatedProduct;

          // Atualizar subcategoria
          final updatedSubcategory = subcategory.copyWith(
            produtos: updatedProducts,
          );

          // Atualizar categoria
          final updatedSubcategories = List<SubcategoryEntity>.from(
            category.subcategorias,
          );
          updatedSubcategories[j] = updatedSubcategory;

          final updatedCategory = category.copyWith(
            subcategorias: updatedSubcategories,
          );

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
    // Encontrar e atualizar o produto
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

          // Atualizar lista de produtos (com tipo explícito)
          final updatedProducts = List<ProductEntity>.from(
            subcategory.produtos,
          );
          updatedProducts[prodIndex] = updatedProduct;

          // Atualizar subcategoria
          final updatedSubcategory = subcategory.copyWith(
            produtos: updatedProducts,
          );

          // Atualizar categoria
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
  void updateProductObservations(int productId, String observations) {
    // Encontrar e atualizar o produto
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

          // Atualizar lista de produtos (com tipo explícito)
          final updatedProducts = List<ProductEntity>.from(
            subcategory.produtos,
          );
          updatedProducts[prodIndex] = updatedProduct;

          // Atualizar subcategoria
          final updatedSubcategory = subcategory.copyWith(
            produtos: updatedProducts,
          );

          // Atualizar categoria
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

  /// 🔄 Alterna estado de um indicador do produto e recalcula quantidade
  @action
  void toggleProductIndicator(int productId, int indicatorId) {
    // Encontrar o produto
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];

      for (var j = 0; j < category.subcategorias.length; j++) {
        final subcategory = category.subcategorias[j];

        final productIndex = subcategory.produtos.indexWhere(
          (p) => p.id == productId,
        );

        if (productIndex != -1) {
          final product = subcategory.produtos[productIndex];

          // Encontrar o indicador na lista do produto
          final indicatorIndex = product.indicadoresEtapa.indexWhere(
            (ind) => ind.produtoIndicadorId == indicatorId,
          );

          if (indicatorIndex != -1) {
            final indicator = product.indicadoresEtapa[indicatorIndex];
            final newSelectedState = !indicator.selecionado;

            // Atualizar o indicador
            final updatedIndicator = indicator.copyWith(
              selecionado: newSelectedState,
            );

            // Atualizar lista de indicadores
            final updatedIndicators = List<IndicadorEtapaEntity>.from(
              product.indicadoresEtapa,
            );
            updatedIndicators[indicatorIndex] = updatedIndicator;

            // Atualizar produto com novos indicadores
            var updatedProduct = product.copyWith(
              indicadoresEtapa: updatedIndicators,
            );

            // 🧮 RECALCULAR quantidade baseado nos indicadores selecionados
            if (censoEscolar != null) {
              final novaQuantidade = calculationService.calcularQuantidade(
                updatedProduct,
                censoEscolar,
              );

              // Atualiza o produto com a quantidade recalculada
              updatedProduct = updatedProduct.copyWith(
                quantidade: novaQuantidade.round(),
              );
            }

            // Propagar atualização na árvore
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

            return;
          }
        }
      }
    }
  }

  /// 💾 Salva orçamento editado usando DTO completo
  ///
  /// **NOVO MÉTODO** que substitui o antigo `updateBudget()`
  ///
  /// Permite alterar:
  /// - Produtos (seleção e quantidade) - via DTO
  /// - Status (pendente, aprovado, arquivado, etc)
  /// - Dados gerais (nome, validade, total)
  /// - Estado de arquivamento
  ///
  /// Diferença do método antigo: Usa BudgetUpdateDto para enviar
  /// todos os produtos com seus estados reais ao backend
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
      // 1. Coletar todos os produtos de todas as categorias/subcategorias
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

      // 2. Calcular total
      final totalCalculado = totalValue;

      // Normalizar para meia-noite para cálculo preciso
      final hoje = DateTime.now();
      final hojeNormalizado = DateTime(hoje.year, hoje.month, hoje.day);
      final validadeNormalizada =
          DateTime(validityDate!.year, validityDate!.month, validityDate!.day);
      final diasValidade =
          validadeNormalizada.difference(hojeNormalizado).inDays;

      // 4. Criar DTO de atualização (com dados obrigatórios para versionamento)
      // 🔑 Diferenciação: multi-cidade envia cidadeId=null + array cidades
      //                   comum envia cidadeId + sem array cidades
      final isMultiCity = budgetData!.isMultiCity;

      final updateDto = BudgetUpdateDto(
        nome: budgetName,
        diasValidade: diasValidade > 0 ? diasValidade : 1,
        status: selectedStatus, // ⚠️ Pode ser qualquer status no budget_edit
        isArchived: isArchived, // 📦 Envia estado de arquivamento
        total: totalCalculado,
        // 🔑 Campos obrigatórios para rota de versionamento
        usuarioId: authStore.currentUser?.id ?? budgetData!.userId,
        // Para multi-cidade: cidadeId = null, cidades = array de IDs
        // Para comum: cidadeId = primeiro ID, cidades = null
        cidadeId: isMultiCity ? null : budgetData!.cityIds.firstOrNull,
        cidades: isMultiCity ? budgetData!.cityIds : null,
        produtos: produtosParaSalvar,
      );

      // 5. Chamar UseCase com endpoint correto baseado no tipo de orçamento
      // - Comum: POST /api/orcamentos/{id}/versionar
      // - Multi-cidade: POST /api/orcamentos/{id}/versionar-multi-cidade
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

  // ========== METHODS CENSO ESCOLAR ==========

  /// Converte os dados brutos de cidades (citiesDataRaw) em CensoEscolarEntity
  /// Para multi-cidade, usa censoAgregado; para cidade única, usa CidadeDto
  void _parseCensoEscolarFromCitiesData() {
    if (budgetData == null) {
      censoEscolar = null;
      return;
    }

    // ✅ Prioridade 1: Usar censo_agregado para orçamentos multi-cidade
    if (budgetData!.censoAgregado.isNotEmpty) {
      censoEscolar = CensoEscolarEntity(
        cidadeId: 0,
        cidadeNome: 'Agregado',
        grupos: const [],
        valoresPorEtapa: budgetData!.censoAgregado,
      );
      return;
    }

    // Fallback: Usar citiesDataRaw para orçamento de cidade única
    if (budgetData!.citiesDataRaw.isEmpty) {
      censoEscolar = null;
      return;
    }

    try {
      final cityData = budgetData!.citiesDataRaw.first;

      // ✅ Usar CidadeDto para parsing tipado (igual ao BudgetConfigStore)
      final cidadeDto = CidadeDto.fromJson(cityData);
      final cidade = cidadeDto.toEntity();

      // ✅ Converter CidadeEntity para CensoEscolarEntity
      censoEscolar = _convertCidadeToCensoEscolar(cidade);

      if (censoEscolar != null) {}
    } catch (e) {
      censoEscolar = null;
    }
  }

  /// Atualiza o censo escolar após edição na página de censo
  /// Também atualiza os dados raw da cidade no budgetData
  @action
  void updateCensoEscolar(CensoEscolarEntity updatedCenso) {
    // Guardar censo antigo para verificação de remark
    final oldCenso = censoEscolar;

    censoEscolar = updatedCenso;

    // Atualizar também os dados raw da cidade no budgetData
    if (budgetData != null && budgetData!.citiesDataRaw.isNotEmpty) {
      final updatedCitiesData = budgetData!.citiesDataRaw.map((cityData) {
        final cityId = cityData['idCidades'] ?? cityData['id'];
        if (cityId == updatedCenso.cidadeId) {
          // Atualizar indicadores com novos valores
          return _updateCityDataWithCenso(cityData, updatedCenso);
        }
        return cityData;
      }).toList();

      // Atualizar citiesDataRaw no budgetData
      budgetData = budgetData!.copyWith(citiesDataRaw: updatedCitiesData);
    }

    // Se temos censo antigo, verificar se há produtos para remarcação
    if (oldCenso != null) {
      _checkForProductsToRemark(oldCenso, updatedCenso);
    }
  }

  @action
  Future<void> reloadProductsAfterCensusEdit() async {
    if (budgetData == null) return;

    isLoading = true;
    isLoadingProducts = true;

    try {
      final oldCenso = censoEscolar;

      // Recarregar estrutura completa e produtos (GET /api/orcamentos/{id})
      // Produtos já vêm com quantidades recalculadas na resposta
      await loadBudgetForEdit(budgetData!.id);

      // 3. Verificar se há produtos que precisam de remarcação
      if (oldCenso != null && censoEscolar != null) {
        _checkForProductsToRemark(oldCenso, censoEscolar!);
      }
    } catch (e) {
      error = 'Erro ao recarregar orçamento: $e';
    } finally {
      isLoading = false;
      isLoadingProducts = false;
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

          // Se era 0 e agora > 0, e NÃO está selecionado, adicionar à lista
          if (oldQuantity == 0 && newQuantity > 0 && !product.selecionado) {
            final updatedProduct = product.copyWith(
              quantidade: newQuantity.round(),
            );
            productsToRemark.add(updatedProduct);
          }
        }
      }
    }

    // Atualizar observable com produtos que precisam de remarcação
    productsNeedingRemark.clear();
    productsNeedingRemark.addAll(productsToRemark);

    if (productsToRemark.isNotEmpty) {}
  }

  /// Marca os produtos como selecionados (chamado pela UI após confirmação)
  @action
  void confirmProductRemark() {
    if (productsNeedingRemark.isEmpty) return;

    final productsToRemark = List<ProductEntity>.from(productsNeedingRemark);

    for (final product in productsToRemark) {
      toggleProduct(product.id, true);
    }

    // Limpar lista após confirmação
    productsNeedingRemark.clear();
  }

  /// Rejeita remarcação dos produtos (chamado pela UI)
  @action
  void rejectProductRemark() {
    if (productsNeedingRemark.isEmpty) return;

    // Limpar lista após rejeição
    productsNeedingRemark.clear();
  }

  /// Cria um novo Map de dados da cidade com os valores atualizados do censo
  Map<String, dynamic> _updateCityDataWithCenso(
    Map<String, dynamic> cityData,
    CensoEscolarEntity updatedCenso,
  ) {
    final indicadores = <Map<String, dynamic>>[];

    for (final grupo in updatedCenso.grupos) {
      for (final titulo in grupo.titulos) {
        indicadores.add({
          'idindice_etapa': titulo.id,
          'nome_etapa': titulo.nomeEtapa,
          'titulo_etapa': titulo.tituloExibicao,
          'grupos_grupo_id': grupo.id,
          'grupo': {'grupo_id': grupo.id, 'nome_grupo': grupo.nome},
          'pivot': {
            'cidades_idCidades': updatedCenso.cidadeId,
            'indice_etapa_idindice_etapa': titulo.id,
            'etapa_valor': titulo.valor.toString(),
          },
        });
      }
    }

    return {...cityData, 'cidades_has_indice_etapa': indicadores};
  }

  /// Converte CidadeEntity para CensoEscolarEntity
  /// Método idêntico ao BudgetConfigStore para garantir consistência
  CensoEscolarEntity? _convertCidadeToCensoEscolar(dynamic cidade) {
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
        // ✅ Usa etapa.indiceEtapa.titulo para exibição amigável
        final titulo = CensoTitleEntity(
          id: etapa.indiceEtapaId,
          nomeEtapa: nomeEtapa,
          tituloExibicao:
              etapa.indiceEtapa.titulo, // Usa titulo para exibição amigável
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

      return CensoEscolarEntity(
        cidadeId: cidade.id,
        cidadeNome: cidade.nome,
        grupos: grupos,
        valoresPorEtapa: valoresPorEtapa,
      );
    } catch (e) {
      return null;
    }
  }
}
