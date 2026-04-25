import 'package:mobx/mobx.dart';

import '../../domain/entities/partner.dart';
import '../../domain/repositories/partner_management_repository.dart';

part 'partner_management_store.g.dart';

// ignore: library_private_types_in_public_api
class PartnerManagementStore = _PartnerManagementStoreBase
    with _$PartnerManagementStore;

abstract class _PartnerManagementStoreBase with Store {
  static const _defaultSort = 'tradeName_asc';

  final PartnerManagementRepository partnerManagementRepository;

  _PartnerManagementStoreBase({required this.partnerManagementRepository});

  @observable
  ObservableList<Partner> partners = ObservableList<Partner>();

  @observable
  bool isLoading = false;

  @observable
  bool isLoadingMore = false;

  @observable
  String? error;

  @observable
  int currentPage = 1;

  @observable
  int lastPage = 1;

  @observable
  int totalPartners = 0;

  @observable
  String searchQuery = '';

  @computed
  bool get hasMore => currentPage < lastPage;

  @computed
  List<Partner> get filteredPartners {
    return partners.toList();
  }

  @action
  void setSearchQuery(String query) {
    searchQuery = query;
  }

  @action
  Future<void> loadPartners() async {
    isLoading = true;
    error = null;
    currentPage = 1;
    partners.clear();

    final result = await partnerManagementRepository.listPartners(
      page: 1,
      searchQuery: _effectiveSearchQuery,
      sort: _defaultSort,
    );
    _processResult(result, updateTotal: true);

    isLoading = false;
  }

  @action
  Future<void> loadMorePartners() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    final nextPage = currentPage + 1;

    final result = await partnerManagementRepository.listPartners(
      page: nextPage,
      searchQuery: _effectiveSearchQuery,
      sort: _defaultSort,
    );
    _processResult(result);

    isLoadingMore = false;
  }

  String? get _effectiveSearchQuery {
    final query = searchQuery.trim();
    return query.isEmpty ? null : query;
  }

  void _processResult(dynamic result, {bool updateTotal = false}) {
    result.fold(
      (failure) {
        error = failure.message;
      },
      (paginatedPartners) {
        partners.addAll(paginatedPartners.partners);
        currentPage = paginatedPartners.currentPage;
        lastPage = paginatedPartners.lastPage;
        if (updateTotal) {
          totalPartners = paginatedPartners.total;
        }
      },
    );
  }
}
