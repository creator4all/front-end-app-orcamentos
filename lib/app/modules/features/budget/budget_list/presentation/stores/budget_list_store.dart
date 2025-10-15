import 'package:mobx/mobx.dart';

import '../../domain/entities/budget_entity.dart';
import '../../domain/usecases/delete_budget_usecase.dart';
import '../../domain/usecases/get_budgets_usecase.dart';
import '../../domain/usecases/rename_budget_usecase.dart';

part 'budget_list_store.g.dart';

class BudgetListStore = _BudgetListStoreBase with _$BudgetListStore;

abstract class _BudgetListStoreBase with Store {
  final GetBudgetsUseCase getBudgetsUseCase;
  final RenameBudgetUseCase renameBudgetUseCase;
  final DeleteBudgetUseCase deleteBudgetUseCase;

  _BudgetListStoreBase({
    required this.getBudgetsUseCase,
    required this.renameBudgetUseCase,
    required this.deleteBudgetUseCase,
  });

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  ObservableList<BudgetEntity> items = ObservableList<BudgetEntity>();

  @observable
  ObservableList<BudgetEntity> allItems = ObservableList<BudgetEntity>();

  @observable
  String searchQuery = '';

  @observable
  ObservableSet<String> selectedFilters =
      ObservableSet<String>.of(['pendente']); // Pendente ativo por padrão

  @action
  Future<void> fetch({String? status}) async {
    isLoading = true;
    error = null;

    try {
      print('🔄 [Store] Carregando orçamentos da API...');

      // Chamar UseCase ao invés do service
      final result = await getBudgetsUseCase(status: status);

      // Tratar resultado com Either
      result.fold(
        (failure) {
          print('❌ [Store] Erro ao carregar orçamentos: ${failure.message}');
          error = failure.message;
          allItems.clear();
        },
        (budgets) {
          print('✅ [Store] Orçamentos carregados: ${budgets.length}');
          for (final budget in budgets) {
            print(
                '   - ID: ${budget.id}, Nome: ${budget.nome}, Status: ${budget.status}, Total: R\$ ${budget.total}');
          }
          allItems.clear();
          allItems.addAll(budgets);
        },
      );

      // Aplicar filtros após carregar
      applyFilters();
    } catch (e) {
      print('❌ [Store] Erro inesperado: $e');
      error = 'Erro inesperado: $e';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> refresh() async {
    await fetch();
  }

  @action
  Future<void> renameBudget(int budgetId, String newName) async {
    try {
      print('✏️ [Store] Renomeando orçamento ID: $budgetId para: $newName');

      final result = await renameBudgetUseCase(budgetId, newName);

      result.fold(
        (failure) {
          print('❌ [Store] Erro ao renomear: ${failure.message}');
          error = failure.message;
        },
        (updatedBudget) {
          print('✅ [Store] Orçamento renomeado com sucesso');

          // Atualizar na lista completa
          final index = allItems.indexWhere((b) => b.id == budgetId);
          if (index != -1) {
            allItems[index] = updatedBudget;
          }

          // Reaplicar filtros para atualizar a lista filtrada
          applyFilters();
        },
      );
    } catch (e) {
      print('❌ [Store] Erro inesperado ao renomear: $e');
      error = 'Erro ao renomear orçamento: $e';
    }
  }

  @action
  Future<void> deleteBudget(int budgetId) async {
    try {
      print('🗑️ [Store] Excluindo orçamento ID: $budgetId');

      final result = await deleteBudgetUseCase(budgetId);

      result.fold(
        (failure) {
          print('❌ [Store] Erro ao excluir: ${failure.message}');
          error = failure.message;
        },
        (_) {
          print('✅ [Store] Orçamento excluído com sucesso');

          // Remover da lista completa
          allItems.removeWhere((b) => b.id == budgetId);

          // Reaplicar filtros
          applyFilters();
        },
      );
    } catch (e) {
      print('❌ [Store] Erro inesperado ao excluir: $e');
      error = 'Erro ao excluir orçamento: $e';
    }
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
    selectedFilters.add('pendente'); // Voltar para pendente por padrão
    applyFilters();
  }

  @action
  void applyFilters() {
    // Se nenhum filtro estiver selecionado, mostrar lista vazia
    if (selectedFilters.isEmpty) {
      items.clear();
      print('🔍 [Store] Nenhum filtro selecionado - lista vazia');
      return;
    }

    List<BudgetEntity> filtered = List.from(allItems);

    // Filtrar por status primeiro (obrigatório)
    filtered = filtered.where((item) {
      final status = item.status.toLowerCase();

      // Mapear filtros para status da API
      return selectedFilters.any((filter) {
        switch (filter) {
          case 'pendente':
            return status == 'pendente' || status == 'rascunho';
          case 'expirado':
            return status == 'expirado';
          case 'nao_aprovado':
            return status == 'reprovado' || status == 'não aprovado';
          case 'aprovado':
            return status == 'aprovado';
          case 'arquivado':
            return status == 'arquivado';
          default:
            return false;
        }
      });
    }).toList();

    // Depois filtrar por texto de busca (se houver)
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final nome = item.nome?.toLowerCase() ?? '';
        final query = searchQuery.toLowerCase();
        return nome.contains(query);
      }).toList();
    }

    items.clear();
    items.addAll(filtered);

    print(
        '🔍 [Store] Filtros aplicados: ${items.length} de ${allItems.length} orçamentos');
    print('🔍 [Store] Filtros ativos: ${selectedFilters.toList()}');
  }
}
