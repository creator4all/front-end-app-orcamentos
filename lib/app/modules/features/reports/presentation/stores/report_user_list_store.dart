import 'package:mobx/mobx.dart';

import '../../domain/entities/report_budget.dart';
import '../../domain/entities/report_user.dart';
import '../../domain/repositories/reports_repository.dart';
import 'report_filter_store.dart';

part 'report_user_list_store.g.dart';

class ReportUserListStore = _ReportUserListStoreBase with _$ReportUserListStore;

abstract class _ReportUserListStoreBase with Store {
  final ReportsRepository reportsRepository;
  final ReportFilterStore filterStore;

  _ReportUserListStoreBase({
    required this.reportsRepository,
    required this.filterStore,
  });

  @observable
  ObservableList<ReportUser> allUsers = ObservableList<ReportUser>();

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  int? currentPartnerId;

  @observable
  String? currentPartnerName;

  @computed
  List<ReportUser> get filteredUsers {
    List<ReportUser> result;

    if (filterStore.userSearchQuery.isEmpty) {
      result = allUsers.toList();
    } else {
      final query = filterStore.userSearchQuery.toLowerCase();
      result = allUsers
          .where(
            (user) =>
                user.nome.toLowerCase().contains(query) ||
                user.email.toLowerCase().contains(query) ||
                user.cargo.toLowerCase().contains(query),
          )
          .toList();
    }

    result.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return result;
  }

  @computed
  double get totalVendasGeral {
    return allUsers.fold(0.0, (sum, user) => sum + user.totalVendas);
  }

  @computed
  int get vendedoresCount {
    return allUsers.where((user) => user.isVendedor).length;
  }

  @computed
  int get gestoresCount {
    return allUsers.where((user) => user.isGestor).length;
  }

  int _loadGeneration = 0;

  @observable
  ObservableList<ReportBudget> allPartnerBudgets =
      ObservableList<ReportBudget>();

  /// Mantém o loading até usuários e orçamentos estarem completos. A publicação
  /// é atômica: sem contadores zerados/parciais enquanto outra página carrega.
  @action
  Future<void> loadUsers(int partnerId, {String? partnerName}) async {
    final generation = ++_loadGeneration;
    currentPartnerId = partnerId;
    currentPartnerName = partnerName;
    final start = filterStore.dataInicio;
    final end = filterStore.dataFim;
    allUsers.clear();
    allPartnerBudgets.clear();
    error = filterStore.dateRangeError;
    isLoading = error == null;
    if (error != null) return;
    try {
      final usersResult = await reportsRepository.getPartnerUsers(partnerId);
      if (generation != _loadGeneration) return;
      final users = usersResult.fold(
        (failure) {
          error = failure.message;
          return null;
        },
        (users) => users,
      );
      if (users == null) return;
      final budgetsResult = await reportsRepository.getPartnerSales(partnerId,
          dataInicio: start, dataFim: end);
      if (generation != _loadGeneration) return;
      budgetsResult.fold(
        (failure) => error = failure.message,
        (budgets) {
          allUsers.addAll(users);
          final userIds = users.map((user) => user.id).toSet();
          allPartnerBudgets.addAll(
              budgets.where((budget) => userIds.contains(budget.usuarioId)));
          _updateUserCounters();
        },
      );
    } catch (_) {
      if (generation == _loadGeneration) {
        error = 'Não foi possível carregar o relatório. Tente novamente.';
      }
    } finally {
      if (generation == _loadGeneration) isLoading = false;
    }
  }

  @action
  Future<void> loadPartnerSales(int partnerId) =>
      loadUsers(partnerId, partnerName: currentPartnerName);

  void _updateUserCounters() {
    final userBudgets = <int, List<ReportBudget>>{};
    for (final budget
        in allPartnerBudgets.where((budget) => !budget.isArchived)) {
      userBudgets.putIfAbsent(budget.usuarioId, () => []).add(budget);
    }

    final updatedUsers = allUsers.map((user) {
      final budgets = userBudgets[user.id] ?? [];
      final aprovados =
          budgets.where((b) => b.status.toLowerCase() == 'aprovado').length;
      final pendentes =
          budgets.where((b) => b.status.toLowerCase() == 'pendente').length;
      final expirados =
          budgets.where((b) => b.status.toLowerCase() == 'expirado').length;
      final naoAprovados = budgets
          .where(
            (b) =>
                b.status.toLowerCase() == 'nao_aprovado' ||
                b.status.toLowerCase() == 'não aprovado',
          )
          .length;
      final totalVendas = budgets.fold<double>(
        0.0,
        (sum, b) => sum + b.total,
      );

      return ReportUser(
        id: user.id,
        nome: user.nome,
        email: user.email,
        cargo: user.cargo,
        totalVendas: totalVendas,
        aprovados: aprovados,
        pendentes: pendentes,
        expirados: expirados,
        naoAprovados: naoAprovados,
        rascunhos:
            budgets.where((b) => b.status.toLowerCase() == 'rascunho').length,
      );
    }).toList();

    allUsers.clear();
    allUsers.addAll(updatedUsers);
  }

  @action
  Future<void> refresh() async {
    if (currentPartnerId != null) {
      await loadUsers(currentPartnerId!, partnerName: currentPartnerName);
    }
  }

  @action
  void clear() {
    _loadGeneration++;
    isLoading = false;
    allUsers.clear();
    allPartnerBudgets.clear();
    error = null;
    currentPartnerId = null;
    currentPartnerName = null;
  }
}
