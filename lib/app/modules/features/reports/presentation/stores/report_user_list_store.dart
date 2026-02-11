import 'package:mobx/mobx.dart';

import '../../domain/entities/report_budget.dart';
import '../../domain/entities/report_user.dart';
import '../../domain/repositories/reports_repository.dart';
import 'report_filter_store.dart';

part 'report_user_list_store.g.dart';

/// Store MobX para gerenciar a lista de usuários com estatísticas.
///
/// Responsável por buscar, filtrar e exibir os usuários de uma empresa
/// com suas estatísticas de vendas.
class ReportUserListStore = _ReportUserListStoreBase with _$ReportUserListStore;

abstract class _ReportUserListStoreBase with Store {
  final ReportsRepository reportsRepository;
  final ReportFilterStore filterStore;

  _ReportUserListStoreBase({
    required this.reportsRepository,
    required this.filterStore,
  });

  /// Lista completa de usuários carregados da API
  @observable
  ObservableList<ReportUser> allUsers = ObservableList<ReportUser>();

  /// Indica se está carregando dados
  @observable
  bool isLoading = false;

  /// Mensagem de erro, se houver
  @observable
  String? error;

  /// ID do parceiro atual
  @observable
  int? currentPartnerId;

  /// Nome do parceiro atual
  @observable
  String? currentPartnerName;

  /// Usuários filtrados pela busca e ordenados por nome
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

    // Ordenar por nome alfabeticamente
    result.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return result;
  }

  /// Soma total de vendas de todos os usuários
  @computed
  double get totalVendasGeral {
    return allUsers.fold(0.0, (sum, user) => sum + user.totalVendas);
  }

  /// Contagem de vendedores
  @computed
  int get vendedoresCount {
    return allUsers.where((user) => user.isVendedor).length;
  }

  /// Contagem de gestores
  @computed
  int get gestoresCount {
    return allUsers.where((user) => user.isGestor).length;
  }

  /// Carrega os usuários de um parceiro
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

  /// Orçamentos do parceiro para cálculo de contadores
  @observable
  ObservableList<ReportBudget> allPartnerBudgets =
      ObservableList<ReportBudget>();

  /// Carrega as vendas do parceiro e atualiza os contadores dos usuários
  @action
  Future<void> loadPartnerSales(int partnerId) async {
    final result = await reportsRepository.getPartnerSales(
      partnerId,
      dataInicio: filterStore.dataInicio,
      dataFim: filterStore.dataFim,
    );

    result.fold(
      (failure) {
        // Se falhar, mantemos os dados existentes
        // Os contadores virão zerados se não houver dados
      },
      (budgets) {
        allPartnerBudgets.clear();
        allPartnerBudgets.addAll(budgets);
        _updateUserCounters();
      },
    );
  }

  /// Atualiza os contadores de cada usuário baseado nos orçamentos
  void _updateUserCounters() {
    // Agrupar orçamentos por usuário
    final userBudgets = <int, List<ReportBudget>>{};
    for (final budget in allPartnerBudgets) {
      userBudgets.putIfAbsent(budget.usuarioId, () => []).add(budget);
    }

    // Atualizar cada usuário com os contadores calculados
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

  /// Recarrega os usuários mantendo os filtros atuais
  @action
  Future<void> refresh() async {
    if (currentPartnerId != null) {
      await loadUsers(currentPartnerId!, partnerName: currentPartnerName);
      await loadPartnerSales(currentPartnerId!);
    }
  }

  /// Limpa a store
  @action
  void clear() {
    allUsers.clear();
    allPartnerBudgets.clear();
    error = null;
    currentPartnerId = null;
    currentPartnerName = null;
  }
}
