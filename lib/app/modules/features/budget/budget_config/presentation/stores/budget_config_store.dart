import 'package:dartz/dartz.dart';
import 'package:mobx/mobx.dart';

import '../../../shared/errors/budget_failure.dart';
import '../../domain/entities/budget_detail_entity.dart';
import '../../domain/entities/census_data_entity.dart';
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

  // ========== COMPUTED ==========

  @computed
  bool get canFinalize {
    if (budgetDetail == null) return false;
    if (validityDate == null) return false;

    // Pelo menos uma categoria deve estar selecionada
    final hasSelectedCategory = categoryStates.values.any((value) => value);
    return hasSelectedCategory;
  }

  @computed
  int get selectedCategoriesCount {
    return categoryStates.values.where((value) => value).length;
  }

  @computed
  double get totalValue {
    if (budgetDetail == null) return 0.0;
    return calculateTotalsUseCase(budgetDetail!.products);
  }

  @computed
  int get selectedProductsCount {
    if (budgetDetail == null) return 0;
    return calculateTotalsUseCase.countSelectedProducts(budgetDetail!.products);
  }

  @computed
  bool get hasData => budgetDetail != null;

  @computed
  bool get hasCensusData => censusData != null && censusData!.hasData;

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
          budgetDetail = budget;

          // Inicializar estados de categorias
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

  @action
  void reset() {
    budgetDetail = null;
    censusData = null;
    categoryStates.clear();
    validityDate = null;
    budgetName = null;
    error = null;
    isLoading = false;
    isLoadingCensus = false;
    isSaving = false;
  }
}
