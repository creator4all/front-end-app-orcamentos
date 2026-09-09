import 'package:mobx/mobx.dart';

import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_list_repository.dart';
import '../../domain/usecases/rename_budget_usecase.dart';

part 'budget_list_store.g.dart';

class BudgetListStore = _BudgetListStoreBase with _$BudgetListStore;

abstract class _BudgetListStoreBase with Store {
  final BudgetListRepository budgetListRepository;
  final RenameBudgetUseCase renameBudgetUseCase;

  _BudgetListStoreBase({
    required this.budgetListRepository,
    required this.renameBudgetUseCase,
  });

  @observable
  bool isLoading = false;

  @observable
  bool isLoadingMore = false;

  @observable
  int currentPage = 1;

  @observable
  int lastPage = 1;

  @observable
  int total = 0;

  String? _status;

  @computed
  bool get hasMore => currentPage < lastPage;

  @observable
  bool needsRefresh = false;

  @observable
  String? error;

  @observable
  ObservableList<BudgetEntity> items = ObservableList<BudgetEntity>();

  @observable
  ObservableList<BudgetEntity> allItems = ObservableList<BudgetEntity>();

  @observable
  String searchQuery = '';

  @observable
  ObservableSet<String> selectedFilters = ObservableSet<String>.of([
    'pendente',
  ]);

  @action
  Future<void> fetch({String? status}) async {
    isLoading = true;
    error = null;
    _status = status;

    try {
      final result = await budgetListRepository.getBudgets(
        status: status,
        page: 1,
      );

      result.fold(
        (failure) {
          error = failure.message;
          allItems.clear();
          currentPage = 1;
          lastPage = 1;
          total = 0;
        },
        (page) {
          allItems.clear();
          allItems.addAll(page.budgets);
          currentPage = page.currentPage;
          lastPage = page.lastPage;
          total = page.total;
          _sortAllItems();
        },
      );

      applyFilters();
    } catch (e) {
      error = 'Erro inesperado: $e';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> refresh() async {
    await fetch(status: _status);
  }

  @action
  Future<void> loadMore() async {
    if (isLoading || isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    error = null;

    try {
      final result = await budgetListRepository.getBudgets(
        status: _status,
        page: currentPage + 1,
      );

      result.fold(
        (failure) => error = failure.message,
        (page) {
          final loadedIds = allItems.map((item) => item.id).toSet();
          allItems.addAll(
            page.budgets.where((budget) => !loadedIds.contains(budget.id)),
          );
          currentPage = page.currentPage;
          lastPage = page.lastPage;
          total = page.total;
          _sortAllItems();
          applyFilters();
        },
      );
    } catch (e) {
      error = 'Erro inesperado: $e';
    } finally {
      isLoadingMore = false;
    }
  }

  @action
  Future<void> refreshWithLoadingState() async {
    items.clear();
    allItems.clear();
    await fetch(status: _status);
  }

  @action
  void reset() {
    allItems.clear();
    items.clear();
    error = null;
    isLoading = false;
    isLoadingMore = false;
    currentPage = 1;
    lastPage = 1;
    total = 0;
    _status = null;
    needsRefresh = false;
  }

  @action
  void markNeedsRefresh() {
    needsRefresh = true;
  }

  @action
  Future<void> renameBudget(int budgetId, String newName) async {
    try {
      final result = await renameBudgetUseCase(budgetId, newName);

      result.fold(
        (failure) {
          error = failure.message;
        },
        (updatedBudget) {
          final index = allItems.indexWhere((b) => b.id == budgetId);
          if (index != -1) {
            allItems[index] = updatedBudget;
          }

          applyFilters();
        },
      );
    } catch (e) {
      error = 'Erro ao renomear orçamento: $e';
    }
  }

  @action
  Future<void> deleteBudget(int budgetId) async {
    try {
      final result = await budgetListRepository.deleteBudget(budgetId);

      result.fold(
        (failure) {
          error = failure.message;
        },
        (_) {
          allItems.removeWhere((b) => b.id == budgetId);
          applyFilters();
        },
      );
    } catch (e) {
      error = 'Erro ao excluir orçamento: $e';
    }
  }

  @action
  void applyBudgetPatch({
    required int budgetId,
    String? nome,
    int? diasValidade,
    DateTime? dataValidade,
    String? status,
    bool? isArchived,
    double? total,
  }) {
    final index = allItems.indexWhere((b) => b.id == budgetId);
    if (index == -1) return;

    final current = allItems[index];

    allItems[index] = BudgetEntity(
      id: current.id,
      nome: nome ?? current.nome,
      diasValidade: diasValidade ?? current.diasValidade,
      dataValidade: dataValidade ?? current.dataValidade,
      status: status ?? current.status,
      isArchived: isArchived ?? current.isArchived,
      total: total ?? current.total,
      cidadesCount: current.cidadesCount,
      criadoPorAdmin: current.criadoPorAdmin,
      partnerDestinoId: current.partnerDestinoId,
      usuarioId: current.usuarioId,
      usuarioNome: current.usuarioNome,
      empresaRazaoSocial: current.empresaRazaoSocial,
    );

    applyFilters();
  }

  @action
  void setSearchQuery(String query) {
    searchQuery = query;
    applyFilters();
  }

  @action
  void toggleFilter(String filter) {
    if (selectedFilters.contains(filter)) {
      selectedFilters.remove(filter);
    } else {
      selectedFilters.add(filter);
    }
    applyFilters();
  }

  @action
  void resetFilters() {
    searchQuery = '';
    selectedFilters.clear();
    selectedFilters.add('pendente');
    applyFilters();
  }

  void _sortAllItems() {
    allItems.sort((a, b) {
      final idComparison = b.id.compareTo(a.id);
      if (idComparison != 0) return idComparison;

      if (a.dataValidade != null && b.dataValidade != null) {
        return b.dataValidade!.compareTo(a.dataValidade!);
      }

      return 0;
    });
  }

  @action
  void applyFilters() {
    if (selectedFilters.isEmpty) {
      items.clear();
      return;
    }

    final isArchivedFilter = selectedFilters.contains('arquivado');

    final statusFilters =
        selectedFilters.where((f) => f != 'arquivado').toSet();

    List<BudgetEntity> filtered =
        allItems.where((item) => item.isArchived == isArchivedFilter).toList();

    if (statusFilters.isNotEmpty) {
      filtered = filtered.where((item) {
        final status = item.status.toLowerCase();

        return statusFilters.any((filter) {
          switch (filter) {
            case 'pendente':
              return status == 'pendente';
            case 'expirado':
              return status == 'expirado';
            case 'nao_aprovado':
              return status == 'nao_aprovado';
            case 'aprovado':
              return status == 'aprovado';
            default:
              return false;
          }
        });
      }).toList();
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final nome = item.nome?.toLowerCase() ?? '';
        final query = searchQuery.toLowerCase();
        return nome.contains(query);
      }).toList();
    }

    items.clear();
    items.addAll(filtered);
  }
}
