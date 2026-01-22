import 'package:mobx/mobx.dart';

import '../../domain/entities/report_budget.dart';
import '../../domain/usecases/get_user_budgets_usecase.dart';
import 'report_filter_store.dart';

part 'report_budget_list_store.g.dart';

/// Store MobX para gerenciar a lista de orçamentos de um usuário.
///
/// Responsável por buscar, filtrar e exibir os orçamentos criados
/// por um usuário específico.
class ReportBudgetListStore = _ReportBudgetListStoreBase
    with _$ReportBudgetListStore;

abstract class _ReportBudgetListStoreBase with Store {
  final GetUserBudgetsUsecase getUserBudgetsUsecase;
  final ReportFilterStore filterStore;

  _ReportBudgetListStoreBase({
    required this.getUserBudgetsUsecase,
    required this.filterStore,
  });

  /// Lista completa de orçamentos carregados da API
  @observable
  ObservableList<ReportBudget> allBudgets = ObservableList<ReportBudget>();

  /// Indica se está carregando dados
  @observable
  bool isLoading = false;

  /// Mensagem de erro, se houver
  @observable
  String? error;

  /// ID do usuário atual
  @observable
  int? currentUserId;

  /// Nome do usuário atual
  @observable
  String? currentUserName;

  /// Cargo do usuário atual
  @observable
  String? currentUserCargo;

  /// Nome do parceiro (empresa)
  @observable
  String? currentPartnerName;

  /// Orçamentos filtrados por busca e status
  @computed
  List<ReportBudget> get filteredBudgets {
    var result = allBudgets.toList();

    // Filtrar por busca
    if (filterStore.budgetSearchQuery.isNotEmpty) {
      final query = filterStore.budgetSearchQuery.toLowerCase();
      result = result
          .where((budget) =>
              (budget.nome?.toLowerCase().contains(query) ?? false) ||
              budget.codigo.toLowerCase().contains(query))
          .toList();
    }

    // Filtrar por status
    if (filterStore.selectedStatuses.isNotEmpty) {
      result = result
          .where((budget) => filterStore.selectedStatuses
              .contains(budget.status.toLowerCase()))
          .toList();
    }

    return result;
  }

  /// Contagem de orçamentos por status
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

  /// Valor total dos orçamentos filtrados
  @computed
  double get totalValue {
    return filteredBudgets.fold(0.0, (sum, budget) => sum + budget.total);
  }

  /// Carrega os orçamentos de um usuário
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

    final result = await getUserBudgetsUsecase(
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

  /// Recarrega os orçamentos mantendo os filtros atuais
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
