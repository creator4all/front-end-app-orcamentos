import 'package:mobx/mobx.dart';

part 'report_filter_store.g.dart';

/// Store MobX para gerenciar filtros globais do módulo de relatórios.
///
/// Os filtros de data são propagados da lista de usuários para a lista de orçamentos,
/// garantindo consistência na navegação.
class ReportFilterStore = _ReportFilterStoreBase with _$ReportFilterStore;

abstract class _ReportFilterStoreBase with Store {
  /// Data inicial do filtro
  @observable
  DateTime? dataInicio;

  /// Data final do filtro
  @observable
  DateTime? dataFim;

  /// Query de busca para lista de usuários
  @observable
  String userSearchQuery = '';

  /// Query de busca para lista de orçamentos
  @observable
  String budgetSearchQuery = '';

  /// Status selecionados para filtrar orçamentos
  @observable
  ObservableSet<String> selectedStatuses = ObservableSet<String>();

  /// Verifica se há algum filtro de data aplicado
  @computed
  bool get hasDateFilter => dataInicio != null || dataFim != null;

  /// Verifica se há algum filtro de status aplicado
  @computed
  bool get hasStatusFilter => selectedStatuses.isNotEmpty;

  /// Define o range de datas
  @action
  void setDateRange(DateTime? inicio, DateTime? fim) {
    dataInicio = inicio;
    dataFim = fim;
  }

  /// Define a data inicial
  @action
  void setDataInicio(DateTime? date) {
    dataInicio = date;
  }

  /// Define a data final
  @action
  void setDataFim(DateTime? date) {
    dataFim = date;
  }

  /// Define a query de busca de usuários
  @action
  void setUserSearchQuery(String query) {
    userSearchQuery = query.trim();
  }

  /// Define a query de busca de orçamentos
  @action
  void setBudgetSearchQuery(String query) {
    budgetSearchQuery = query.trim();
  }

  /// Alterna a seleção de um status
  @action
  void toggleStatus(String status) {
    if (selectedStatuses.contains(status)) {
      selectedStatuses.remove(status);
    } else {
      selectedStatuses.add(status);
    }
  }

  /// Define os status selecionados
  @action
  void setSelectedStatuses(Set<String> statuses) {
    selectedStatuses.clear();
    selectedStatuses.addAll(statuses);
  }

  /// Limpa todos os filtros de status
  @action
  void clearStatusFilter() {
    selectedStatuses.clear();
  }

  /// Limpa os filtros de data
  @action
  void clearDateFilter() {
    dataInicio = null;
    dataFim = null;
  }

  /// Limpa todos os filtros e define datas padrão (hoje até +7 dias)
  @action
  void resetFilters() {
    final now = DateTime.now();
    dataInicio = DateTime(now.year, now.month, now.day);
    dataFim =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 7));
    userSearchQuery = '';
    budgetSearchQuery = '';
    selectedStatuses.clear();
  }

  /// Limpa apenas os filtros de busca de usuários
  @action
  void clearUserSearch() {
    userSearchQuery = '';
  }

  /// Limpa apenas os filtros de busca de orçamentos
  @action
  void clearBudgetSearch() {
    budgetSearchQuery = '';
  }
}
