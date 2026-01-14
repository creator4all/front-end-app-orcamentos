import 'package:mobx/mobx.dart';

import '../../domain/entities/partner.dart';
import '../../domain/usecases/list_partners_usecase.dart';

part 'partner_management_store.g.dart';

/// Store MobX para gerenciamento de estado da tela de gestão de parceiros
class PartnerManagementStore = _PartnerManagementStoreBase
    with _$PartnerManagementStore;

abstract class _PartnerManagementStoreBase with Store {
  final ListPartnersUsecase listPartnersUsecase;

  _PartnerManagementStoreBase({
    required this.listPartnersUsecase,
  });

  // ========== OBSERVABLES ==========

  /// Lista de parceiros carregados
  @observable
  ObservableList<Partner> partners = ObservableList<Partner>();

  /// Estado de carregamento inicial
  @observable
  bool isLoading = false;

  /// Estado de carregamento de mais itens (scroll infinito)
  @observable
  bool isLoadingMore = false;

  /// Mensagem de erro
  @observable
  String? error;

  /// Página atual
  @observable
  int currentPage = 1;

  /// Total de páginas
  @observable
  int lastPage = 1;

  /// Total de parceiros
  @observable
  int totalPartners = 0;

  /// Query de busca
  @observable
  String searchQuery = '';

  // ========== COMPUTED ==========

  /// Verifica se há mais páginas para carregar
  @computed
  bool get hasMore => currentPage < lastPage;

  /// Lista filtrada de parceiros
  @computed
  List<Partner> get filteredPartners {
    if (searchQuery.isEmpty) {
      return partners.toList();
    }
    final query = searchQuery.toLowerCase();
    return partners.where((partner) {
      return partner.tradeName.toLowerCase().contains(query) ||
          partner.legalName.toLowerCase().contains(query) ||
          partner.cnpj.contains(query);
    }).toList();
  }

  // ========== ACTIONS ==========

  /// Define a query de busca
  @action
  void setSearchQuery(String query) {
    searchQuery = query;
  }

  /// Carrega a lista inicial de parceiros
  @action
  Future<void> loadPartners() async {
    isLoading = true;
    error = null;
    currentPage = 1;
    partners.clear();

    print('📋 [PartnerManagementStore] Carregando parceiros...');

    final result = await listPartnersUsecase(page: 1);

    result.fold(
      (failure) {
        error = failure.message;
        print('❌ [PartnerManagementStore] Erro: ${failure.message}');
      },
      (paginatedPartners) {
        partners.addAll(paginatedPartners.partners);
        currentPage = paginatedPartners.currentPage;
        lastPage = paginatedPartners.lastPage;
        totalPartners = paginatedPartners.total;
        print(
            '✅ [PartnerManagementStore] Carregados ${partners.length} parceiros');
      },
    );

    isLoading = false;
  }

  /// Carrega mais parceiros (scroll infinito)
  @action
  Future<void> loadMorePartners() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    final nextPage = currentPage + 1;

    print('📋 [PartnerManagementStore] Carregando página $nextPage...');

    final result = await listPartnersUsecase(page: nextPage);

    result.fold(
      (failure) {
        error = failure.message;
        print('❌ [PartnerManagementStore] Erro: ${failure.message}');
      },
      (paginatedPartners) {
        partners.addAll(paginatedPartners.partners);
        currentPage = paginatedPartners.currentPage;
        lastPage = paginatedPartners.lastPage;
        print(
            '✅ [PartnerManagementStore] Carregados mais ${paginatedPartners.partners.length} parceiros');
      },
    );

    isLoadingMore = false;
  }
}
