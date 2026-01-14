// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_management_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PartnerManagementStore on _PartnerManagementStoreBase, Store {
  Computed<bool>? _$hasMoreComputed;

  @override
  bool get hasMore => (_$hasMoreComputed ??= Computed<bool>(() => super.hasMore,
          name: '_PartnerManagementStoreBase.hasMore'))
      .value;
  Computed<List<Partner>>? _$filteredPartnersComputed;

  @override
  List<Partner> get filteredPartners => (_$filteredPartnersComputed ??=
          Computed<List<Partner>>(() => super.filteredPartners,
              name: '_PartnerManagementStoreBase.filteredPartners'))
      .value;

  late final _$partnersAtom =
      Atom(name: '_PartnerManagementStoreBase.partners', context: context);

  @override
  ObservableList<Partner> get partners {
    _$partnersAtom.reportRead();
    return super.partners;
  }

  @override
  set partners(ObservableList<Partner> value) {
    _$partnersAtom.reportWrite(value, super.partners, () {
      super.partners = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_PartnerManagementStoreBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$isLoadingMoreAtom =
      Atom(name: '_PartnerManagementStoreBase.isLoadingMore', context: context);

  @override
  bool get isLoadingMore {
    _$isLoadingMoreAtom.reportRead();
    return super.isLoadingMore;
  }

  @override
  set isLoadingMore(bool value) {
    _$isLoadingMoreAtom.reportWrite(value, super.isLoadingMore, () {
      super.isLoadingMore = value;
    });
  }

  late final _$errorAtom =
      Atom(name: '_PartnerManagementStoreBase.error', context: context);

  @override
  String? get error {
    _$errorAtom.reportRead();
    return super.error;
  }

  @override
  set error(String? value) {
    _$errorAtom.reportWrite(value, super.error, () {
      super.error = value;
    });
  }

  late final _$currentPageAtom =
      Atom(name: '_PartnerManagementStoreBase.currentPage', context: context);

  @override
  int get currentPage {
    _$currentPageAtom.reportRead();
    return super.currentPage;
  }

  @override
  set currentPage(int value) {
    _$currentPageAtom.reportWrite(value, super.currentPage, () {
      super.currentPage = value;
    });
  }

  late final _$lastPageAtom =
      Atom(name: '_PartnerManagementStoreBase.lastPage', context: context);

  @override
  int get lastPage {
    _$lastPageAtom.reportRead();
    return super.lastPage;
  }

  @override
  set lastPage(int value) {
    _$lastPageAtom.reportWrite(value, super.lastPage, () {
      super.lastPage = value;
    });
  }

  late final _$totalPartnersAtom =
      Atom(name: '_PartnerManagementStoreBase.totalPartners', context: context);

  @override
  int get totalPartners {
    _$totalPartnersAtom.reportRead();
    return super.totalPartners;
  }

  @override
  set totalPartners(int value) {
    _$totalPartnersAtom.reportWrite(value, super.totalPartners, () {
      super.totalPartners = value;
    });
  }

  late final _$searchQueryAtom =
      Atom(name: '_PartnerManagementStoreBase.searchQuery', context: context);

  @override
  String get searchQuery {
    _$searchQueryAtom.reportRead();
    return super.searchQuery;
  }

  @override
  set searchQuery(String value) {
    _$searchQueryAtom.reportWrite(value, super.searchQuery, () {
      super.searchQuery = value;
    });
  }

  late final _$loadPartnersAsyncAction =
      AsyncAction('_PartnerManagementStoreBase.loadPartners', context: context);

  @override
  Future<void> loadPartners() {
    return _$loadPartnersAsyncAction.run(() => super.loadPartners());
  }

  late final _$loadMorePartnersAsyncAction = AsyncAction(
      '_PartnerManagementStoreBase.loadMorePartners',
      context: context);

  @override
  Future<void> loadMorePartners() {
    return _$loadMorePartnersAsyncAction.run(() => super.loadMorePartners());
  }

  late final _$_PartnerManagementStoreBaseActionController =
      ActionController(name: '_PartnerManagementStoreBase', context: context);

  @override
  void setSearchQuery(String query) {
    final _$actionInfo = _$_PartnerManagementStoreBaseActionController
        .startAction(name: '_PartnerManagementStoreBase.setSearchQuery');
    try {
      return super.setSearchQuery(query);
    } finally {
      _$_PartnerManagementStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
partners: ${partners},
isLoading: ${isLoading},
isLoadingMore: ${isLoadingMore},
error: ${error},
currentPage: ${currentPage},
lastPage: ${lastPage},
totalPartners: ${totalPartners},
searchQuery: ${searchQuery},
hasMore: ${hasMore},
filteredPartners: ${filteredPartners}
    ''';
  }
}
