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
      result =
          allUsers
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
  @action
  Future<void> loadUsers(int partnerId, {String? partnerName}) async {
    currentPartnerId = partnerId;
    currentPartnerName = partnerName;
    isLoading = true;
    error = null;

    final result = await reportsRepository.getPartnerUsers(
      partnerId,
      dataInicio: filterStore.dataInicio,
      dataFim: filterStore.dataFim,
    );

    result.fold(
      (failure) {
        error = failure.message;
        isLoading = false;
      },
      (users) {
        allUsers.clear();
        allUsers.addAll(users);
        isLoading = false;
      },
    );
  }

  @observable
  ObservableList<ReportBudget> allPartnerBudgets =
      ObservableList<ReportBudget>();
  @action
  Future<void> loadPartnerSales(int partnerId) async {
    final result = await reportsRepository.getPartnerSales(
      partnerId,
      dataInicio: filterStore.dataInicio,
      dataFim: filterStore.dataFim,
    );

    result.fold(
      (failure) {
      },
      (budgets) {
        allPartnerBudgets.clear();
        allPartnerBudgets.addAll(budgets);
        _updateUserCounters();
      },
    );
  }

  void _updateUserCounters() {
    final userBudgets = <int, List<ReportBudget>>{};
    for (final budget in allPartnerBudgets) {
      userBudgets.putIfAbsent(budget.usuarioId, () => []).add(budget);
    }

    final updatedUsers =
        allUsers.map((user) {
          final budgets = userBudgets[user.id] ?? [];
          final aprovados =
              budgets.where((b) => b.status.toLowerCase() == 'aprovado').length;
          final pendentes =
              budgets.where((b) => b.status.toLowerCase() == 'pendente').length;
          final expirados =
              budgets.where((b) => b.status.toLowerCase() == 'expirado').length;
          final naoAprovados =
              budgets
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
          );
        }).toList();

    allUsers.clear();
    allUsers.addAll(updatedUsers);
  }

  @action
  Future<void> refresh() async {
    if (currentPartnerId != null) {
      await loadUsers(currentPartnerId!, partnerName: currentPartnerName);
      await loadPartnerSales(currentPartnerId!);
    }
  }

  @action
  void clear() {
    allUsers.clear();
    allPartnerBudgets.clear();
    error = null;
    currentPartnerId = null;
    currentPartnerName = null;
  }
}
