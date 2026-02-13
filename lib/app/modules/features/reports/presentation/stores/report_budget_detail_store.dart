import 'package:mobx/mobx.dart';

import '../../../budget/budget_config/data/models/budget_census_dto.dart';
import '../../../budget/budget_config/domain/entities/budget_detail_entity.dart';
import '../../../budget/budget_config/domain/usecases/get_budget_census_usecase.dart';
import '../../../budget/budget_config/domain/usecases/get_budget_detail_usecase.dart';

part 'report_budget_detail_store.g.dart';

class ReportBudgetDetailStore = _ReportBudgetDetailStoreBase
    with _$ReportBudgetDetailStore;

abstract class _ReportBudgetDetailStoreBase with Store {
  final GetBudgetDetailUseCase getBudgetDetailUseCase;
  final GetBudgetCensusUseCase getBudgetCensusUseCase;

  _ReportBudgetDetailStoreBase({
    required this.getBudgetDetailUseCase,
    required this.getBudgetCensusUseCase,
  });

  @observable
  BudgetDetailEntity? budgetDetail;

  @observable
  BudgetCensusDto? censoEscolar;

  @observable
  bool isLoadingBudget = false;

  @observable
  bool isLoadingCensus = false;

  @observable
  String? error;

  @observable
  int? currentBudgetId;

  @computed
  bool get isLoading => isLoadingBudget || isLoadingCensus;

  @computed
  String get budgetName => budgetDetail?.name ?? 'Orçamento';

  @computed
  String get budgetStatus => budgetDetail?.status ?? '';

  @computed
  double get budgetTotal => budgetDetail?.total ?? 0.0;

  @computed
  int get validityDays => budgetDetail?.validityDays ?? 0;

  @computed
  bool get hasCensus => censoEscolar != null;

  @computed
  bool get isMultiCity => budgetDetail?.isMultiCity ?? false;
  @computed
  int get selectedItemsCount {
    if (budgetDetail == null) return 0;

    return budgetDetail!.categories.fold(0, (sum, category) {
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

  @action
  Future<void> loadBudgetDetails(int budgetId) async {
    currentBudgetId = budgetId;
    error = null;

    await Future.wait([
      _loadBudget(budgetId),
      _loadCensus(budgetId),
    ]);
  }

  @action
  Future<void> _loadBudget(int budgetId) async {
    isLoadingBudget = true;

    final result = await getBudgetDetailUseCase(budgetId);

    result.fold(
      (failure) {
        error = failure.message;
        isLoadingBudget = false;
      },
      (detail) {
        budgetDetail = detail;
        isLoadingBudget = false;
      },
    );
  }

  @action
  Future<void> _loadCensus(int budgetId) async {
    isLoadingCensus = true;

    final result = await getBudgetCensusUseCase(budgetId);

    result.fold(
      (failure) {
        isLoadingCensus = false;
      },
      (census) {
        censoEscolar = census;
        isLoadingCensus = false;
      },
    );
  }

  @action
  Future<void> refresh() async {
    if (currentBudgetId != null) {
      await loadBudgetDetails(currentBudgetId!);
    }
  }

  @action
  void clear() {
    budgetDetail = null;
    censoEscolar = null;
    error = null;
    currentBudgetId = null;
  }
}
