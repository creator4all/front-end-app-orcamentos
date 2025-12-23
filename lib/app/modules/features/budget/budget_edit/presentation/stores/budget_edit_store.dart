import 'package:dartz/dartz.dart';
import 'package:mobx/mobx.dart';

import '../../../../auth/presentation/stores/auth_store.dart';
import '../../../budget_config/data/models/category_dto.dart';
import '../../../budget_config/domain/entities/category_entity.dart';
import '../../../budget_config/domain/entities/censo_escolar_entity.dart';
import '../../../budget_config/domain/entities/censo_group_entity.dart';
import '../../../budget_config/domain/entities/censo_title_entity.dart';
import '../../../budget_config/domain/entities/census_data_entity.dart';
import '../../../budget_config/domain/entities/product_entity.dart';
import '../../../budget_config/domain/entities/subcategory_entity.dart';
import '../../../budget_config/domain/usecases/get_census_data_usecase.dart';
import '../../../budget_create/data/models/cidade_dto.dart';
import '../../../shared/errors/budget_failure.dart';
import '../../../shared/models/budget_update_dto.dart';
import '../../../shared/models/product_selection_update_dto.dart';
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
  final AuthStore authStore;

  _BudgetEditStoreBase({
    required this.getBudgetForEditUseCase,
    required this.updateBudgetUseCase,
    required this.getCensusDataUseCase,
    required this.getAllProductsUseCase,
    required this.authStore,
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
    // Carrega estrutura completa (categorias, subcategorias, produtos e cidade)
    // A API /api/orcamentos/{id} já retorna TODOS os dados necessários
    await loadBudgetForEdit(budgetId);

    // Nota: Não é mais necessário chamar _loadAllProducts() ou loadCensusData()
    // pois loadBudgetForEdit() já traz todos os dados da API
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

  /// Carrega TODOS os produtos do orçamento com estados reais do banco
  /// e faz merge com a estrutura de categorias/subcategorias
  @action
  Future<void> _loadAllProducts(int budgetId) async {
    isLoadingProducts = true;

    try {
      final result = await getAllProductsUseCase(budgetId: budgetId);

      result.fold(
        (failure) {
          error = failure.message;
          isLoadingProducts = false;
        },
        (allProducts) {
          // Agrupar produtos por subcategoria_id
          final productsBySubcategory = <int, List<ProductEntity>>{};

          for (final product in allProducts) {
            final subId = product.subcategoriaId;
            productsBySubcategory.putIfAbsent(subId, () => []);
            productsBySubcategory[subId]!.add(product);
          }

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

          // Atualizar selectedProductIds baseado nos produtos reais
          _updateSelectedProductIds();

          isLoadingProducts = false;
        },
      );
    } catch (e) {
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
  void toggleCategory(int categoryId) {
    final categoryIndex = categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex != -1) {
      // A CategoryEntity não tem isExpanded
      // A lógica de expansão será gerenciada pela UI
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
      int categoryId, int subcategoryId, bool selected) {
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
            produtosParaSalvar
                .add(ProductSelectionUpdateDto.fromEntity(product));
          }
        }
      }

      // 2. Calcular total
      final totalCalculado = totalValue;

      // 3. Calcular dias de validade
      final diasValidade = validityDate!.difference(DateTime.now()).inDays;

      // 4. Criar DTO de atualização (com dados obrigatórios para versionamento)
      final updateDto = BudgetUpdateDto(
        nome: budgetName,
        diasValidade: diasValidade > 0 ? diasValidade : 1,
        status: selectedStatus, // ⚠️ Pode ser qualquer status no budget_edit
        isArchived: isArchived, // 📦 Envia estado de arquivamento
        total: totalCalculado,
        // 🔑 Campos obrigatórios para rota de versionamento
        usuarioId: authStore.currentUser?.id ?? budgetData!.userId,
        cidadeId:
            budgetData!.cityIds.isNotEmpty ? budgetData!.cityIds.first : null,
        produtos: produtosParaSalvar,
      );

      // 5. Chamar UseCase com DTO (agora versiona em vez de atualizar)
      final result = await updateBudgetUseCase.versionWithDto(
        budgetId: budgetData!.id,
        updateData: updateDto,
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
      error = 'Erro ao salvar orçamento: $e';
      isSaving = false;
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ========== METHODS CENSO ESCOLAR ==========

  /// Converte os dados brutos de cidades (citiesDataRaw) em CensoEscolarEntity
  /// Usa CidadeDto para parsing tipado, igual ao BudgetConfigStore
  void _parseCensoEscolarFromCitiesData() {
    if (budgetData == null || budgetData!.citiesDataRaw.isEmpty) {
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

      if (censoEscolar != null) {
        print(
            '✅ [BudgetEditStore] CensoEscolar parseado: ${censoEscolar!.grupos.length} grupos, ${censoEscolar!.valoresPorEtapa.length} etapas');
      }
    } catch (e) {
      print('❌ [BudgetEditStore] Erro ao parsear censo: $e');
      censoEscolar = null;
    }
  }

  /// Atualiza o censo escolar após edição na página de censo
  /// Também atualiza os dados raw da cidade no budgetData
  @action
  void updateCensoEscolar(CensoEscolarEntity updatedCenso) {
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

    print(
        '✅ [BudgetEditStore] CensoEscolar atualizado: ${censoEscolar!.grupos.length} grupos');
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
          'grupo': {
            'grupo_id': grupo.id,
            'nome_grupo': grupo.nome,
          },
          'pivot': {
            'cidades_idCidades': updatedCenso.cidadeId,
            'indice_etapa_idindice_etapa': titulo.id,
            'etapa_valor': titulo.valor.toString(),
          },
        });
      }
    }

    return {
      ...cityData,
      'cidades_has_indice_etapa': indicadores,
    };
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
      print('❌ [BudgetEditStore] Erro ao converter cidade para censo: $e');
      return null;
    }
  }
}
