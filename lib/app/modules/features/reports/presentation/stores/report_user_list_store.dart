import 'package:mobx/mobx.dart';

import '../../domain/entities/report_user.dart';
import '../../domain/usecases/get_partner_users_usecase.dart';
import 'report_filter_store.dart';

part 'report_user_list_store.g.dart';

/// Store MobX para gerenciar a lista de usuários com estatísticas.
///
/// Responsável por buscar, filtrar e exibir os usuários de uma empresa
/// com suas estatísticas de vendas.
class ReportUserListStore = _ReportUserListStoreBase with _$ReportUserListStore;

abstract class _ReportUserListStoreBase with Store {
  final GetPartnerUsersUsecase getPartnerUsersUsecase;
  final ReportFilterStore filterStore;

  _ReportUserListStoreBase({
    required this.getPartnerUsersUsecase,
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

  /// Usuários filtrados pela busca
  @computed
  List<ReportUser> get filteredUsers {
    if (filterStore.userSearchQuery.isEmpty) {
      return allUsers.toList();
    }

    final query = filterStore.userSearchQuery.toLowerCase();
    return allUsers
        .where((user) =>
            user.nome.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query) ||
            user.cargo.toLowerCase().contains(query))
        .toList();
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

    final result = await getPartnerUsersUsecase(
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

  /// Recarrega os usuários mantendo os filtros atuais
  @action
  Future<void> refresh() async {
    if (currentPartnerId != null) {
      await loadUsers(currentPartnerId!, partnerName: currentPartnerName);
    }
  }

  /// Limpa a store
  @action
  void clear() {
    allUsers.clear();
    error = null;
    currentPartnerId = null;
    currentPartnerName = null;
  }
}
