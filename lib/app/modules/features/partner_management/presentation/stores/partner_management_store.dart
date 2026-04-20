import 'package:mobx/mobx.dart';

import '../../../../../shared/utils/document_validators.dart';
import '../../domain/entities/partner.dart';
import '../../domain/repositories/partner_management_repository.dart';

part 'partner_management_store.g.dart';

class PartnerManagementStore = _PartnerManagementStoreBase
    with _$PartnerManagementStore;

abstract class _PartnerManagementStoreBase with Store {
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
    if (searchQuery.isEmpty) {
      return partners.toList();
    }
    final query = searchQuery.toLowerCase();
    final normalizedQuery = DocumentValidators.normalizeDocument(searchQuery);
    return partners.where((partner) {
      return partner.tradeName.toLowerCase().contains(query) ||
          partner.legalName.toLowerCase().contains(query) ||
          partner.cnpj.contains(query) ||
          DocumentValidators.formatDocument(partner.cnpj)
              .toLowerCase()
              .contains(query) ||
          DocumentValidators.normalizeDocument(partner.cnpj)
              .contains(normalizedQuery);
    }).toList();
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

    final result = await partnerManagementRepository.listPartners(page: 1);
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
    );
    _processResult(result);

    isLoadingMore = false;
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
