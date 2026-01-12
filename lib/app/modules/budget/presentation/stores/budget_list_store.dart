import 'package:mobx/mobx.dart';

import '../../../budget/domain/models/budget_summary.dart';
import '../../../budget/external/services/budget_service.dart';

part 'budget_list_store.g.dart';

class BudgetListStore = _BudgetListStore with _$BudgetListStore;

abstract class _BudgetListStore with Store {
  final BudgetService _service;
  _BudgetListStore(this._service);

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  List<BudgetSummaryDto> items = [];

  @observable
  List<BudgetSummaryDto> allItems = []; // Lista completa sem filtros

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
      print('🔄 Carregando orçamentos da API...');
      allItems = await _service.listar(status: status);
      print('✅ Orçamentos carregados: ${allItems.length}');
      for (final item in allItems) {
        print(
            '   - ID: ${item.id}, Nome: ${item.nome}, Status: ${item.status}, Total: R\$ ${item.total}');
      }

      // Aplicar filtros após carregar
      applyFilters();
    } catch (e) {
      print('❌ Erro ao carregar orçamentos: $e');
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> refresh() async {
    await fetch();
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
      items = [];
      print('🔍 Nenhum filtro selecionado - lista vazia');
      return;
    }

    List<BudgetSummaryDto> filtered = List.from(allItems);

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
            return status == 'nao_aprovado';
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

    items = filtered;
    print(
        '🔍 Filtros aplicados: ${items.length} de ${allItems.length} orçamentos');
    print('🔍 Filtros ativos: ${selectedFilters.toList()}');
  }
}
