import 'package:mobx/mobx.dart';

import '../../domain/entities/prospect_entity.dart';
import '../../domain/repositories/prospect_repository.dart';

part 'prospect_store.g.dart';

class ProspectStore = _ProspectStoreBase with _$ProspectStore;

abstract class _ProspectStoreBase with Store {
  final ProspectRepository prospectRepository;

  _ProspectStoreBase({required this.prospectRepository});

  @observable
  ObservableList<ProspectEntity> prospects = ObservableList<ProspectEntity>();

  @observable
  ObservableList<ProspectEntity> contactedProspects =
      ObservableList<ProspectEntity>();

  @observable
  bool isLoading = false;

  @observable
  bool isLoadingContacted = false;

  @observable
  bool isLoadingMore = false;

  @observable
  bool isLoadingMoreContacted = false;

  @observable
  bool isMarkingContacted = false;

  @observable
  int? markingContactedId;

  @observable
  String? error;

  @observable
  int currentPage = 1;

  @observable
  int lastPage = 1;

  @observable
  int currentPageContacted = 1;

  @observable
  int lastPageContacted = 1;

  @observable
  int totalProspects = 0;

  @observable
  int totalContactedProspects = 0;

  @computed
  bool get hasMore => currentPage < lastPage;

  @computed
  bool get hasMoreContacted => currentPageContacted < lastPageContacted;

  Future<void> _loadProspectsInternal({
    required bool isContacted,
    required bool isLoadMore,
  }) async {
    final targetList = isContacted ? contactedProspects : prospects;
    final currentPageValue = isContacted ? currentPageContacted : currentPage;

    final page = isLoadMore ? currentPageValue + 1 : 1;

    if (isLoadMore) {
      if (isContacted) {
        isLoadingMoreContacted = true;
      } else {
        isLoadingMore = true;
      }
    } else {
      if (isContacted) {
        isLoadingContacted = true;
      } else {
        isLoading = true;
      }
      error = null;
      targetList.clear();
    }

    final result = await prospectRepository.getProspects(
      page: page,
      isContatado: isContacted,
    );

    result.fold(
      (failure) {
        error = failure.message;
      },
      (paginatedProspects) {
        targetList.addAll(paginatedProspects.prospects);
        if (isContacted) {
          currentPageContacted = paginatedProspects.currentPage;
          lastPageContacted = paginatedProspects.lastPage;
          if (!isLoadMore) totalContactedProspects = paginatedProspects.total;
        } else {
          currentPage = paginatedProspects.currentPage;
          lastPage = paginatedProspects.lastPage;
          if (!isLoadMore) totalProspects = paginatedProspects.total;
        }
      },
    );

    if (isLoadMore) {
      if (isContacted) {
        isLoadingMoreContacted = false;
      } else {
        isLoadingMore = false;
      }
    } else {
      if (isContacted) {
        isLoadingContacted = false;
      } else {
        isLoading = false;
      }
    }
  }

  @action
  Future<void> loadProspects() async {
    await _loadProspectsInternal(isContacted: false, isLoadMore: false);
  }

  @action
  Future<void> loadMoreProspects() async {
    if (isLoadingMore || !hasMore) return;
    await _loadProspectsInternal(isContacted: false, isLoadMore: true);
  }

  @action
  Future<void> loadContactedProspects() async {
    await _loadProspectsInternal(isContacted: true, isLoadMore: false);
  }

  @action
  Future<void> loadMoreContactedProspects() async {
    if (isLoadingMoreContacted || !hasMoreContacted) return;
    await _loadProspectsInternal(isContacted: true, isLoadMore: true);
  }

  @action
  Future<bool> markAsContacted(int prospectId) async {
    isMarkingContacted = true;
    markingContactedId = prospectId;
    error = null;

    final result = await prospectRepository.markAsContacted(prospectId);

    bool success = false;

    result.fold(
      (failure) {
        error = failure.message;
      },
      (updatedProspect) {
        prospects.removeWhere((p) => p.id == prospectId);
        totalProspects--;

        if (contactedProspects.isNotEmpty || totalContactedProspects > 0) {
          contactedProspects.insert(0, updatedProspect);
          totalContactedProspects++;
        }

        success = true;
      },
    );

    isMarkingContacted = false;
    markingContactedId = null;
    return success;
  }

  @action
  void clearError() {
    error = null;
  }
}
