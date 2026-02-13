import 'package:mobx/mobx.dart';

import '../../domain/entities/report_budget.dart';
import '../../domain/repositories/reports_repository.dart';
import 'report_filter_store.dart';

part 'report_budget_list_store.g.dart';

class ReportBudgetListStore = _ReportBudgetListStoreBase
    with _$ReportBudgetListStore;

abstract class _ReportBudgetListStoreBase with Store {
  final ReportsRepository reportsRepository;
  final ReportFilterStore filterStore;

  _ReportBudgetListStoreBase({
    required this.reportsRepository,
    required this.filterStore,
  });

  @observable
  ObservableList<ReportBudget> allBudgets = ObservableList<ReportBudget>();

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  int? currentUserId;

  @observable
  String? currentUserName;

  @observable
  String? currentUserCargo;

  @observable
  String? currentPartnerName;

  @computed
  List<ReportBudget> get filteredBudgets {
    var result = allBudgets.toList();

    final isArchivedFilterActive = filterStore.selectedStatuses.contains(
      'arquivado',
    );
    if (isArchivedFilterActive) {
      result = result.where((budget) => budget.isArchived).toList();
    } else {
      result = result.where((budget) => !budget.isArchived).toList();
    }

    if (filterStore.budgetSearchQuery.isNotEmpty) {
      final query = filterStore.budgetSearchQuery.toLowerCase();
      result =
          result
              .where(
                (budget) =>
                    (budget.nome?.toLowerCase().contains(query) ?? false) ||
                    budget.codigo.toLowerCase().contains(query),
              )
              .toList();
    }

    if (filterStore.selectedStatuses.isNotEmpty) {
      final statusFilters =
          filterStore.selectedStatuses.where((s) => s != 'arquivado').toSet();

      if (statusFilters.isNotEmpty) {
        result =
            result
                .where(
                  (budget) =>
                      statusFilters.contains(budget.status.toLowerCase()),
                )
                .toList();
      }
    }

    return result;
  }

  @computed
  Map<String, int> get statusCounts {
    final counts = <String, int>{
      'aprovado': 0,
      'pendente': 0,
      'expirado': 0,
      'nao_aprovado': 0,
      'arquivado': 0,
    };

    for (final budget in allBudgets) {
      final status = budget.status.toLowerCase();
      if (counts.containsKey(status)) {
        counts[status] = counts[status]! + 1;
      }
      if (budget.isArchived) {
        counts['arquivado'] = counts['arquivado']! + 1;
      }
    }

    return counts;
  }

  @computed
  double get totalValue {
    return filteredBudgets.fold(0.0, (sum, budget) => sum + budget.total);
  }
  @action
  Future<void> loadBudgets(
    int userId, {
    String? userName,
    String? userCargo,
    String? partnerName,
  }) async {
    currentUserId = userId;
    currentUserName = userName;
    currentUserCargo = userCargo;
    currentPartnerName = partnerName;
    isLoading = true;
    error = null;

    final result = await reportsRepository.getUserBudgets(
      userId,
      dataInicio: filterStore.dataInicio,
      dataFim: filterStore.dataFim,
    );

    result.fold(
      (failure) {
        error = failure.message;
        isLoading = false;
      },
      (budgets) {
        allBudgets.clear();
        allBudgets.addAll(budgets);
        isLoading = false;
      },
    );
  }

  @action
  Future<void> refresh() async {
    if (currentUserId != null) {
      await loadBudgets(
        currentUserId!,
        userName: currentUserName,
        userCargo: currentUserCargo,
        partnerName: currentPartnerName,
      );
    }
  }

  /// Limpa a store
  @action
  void clear() {
    allBudgets.clear();
    error = null;
    currentUserId = null;
    currentUserName = null;
    currentUserCargo = null;
    currentPartnerName = null;
  }
}
