// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prospect_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProspectStore on _ProspectStoreBase, Store {
  Computed<bool>? _$hasMoreComputed;

  @override
  bool get hasMore => (_$hasMoreComputed ??= Computed<bool>(() => super.hasMore,
          name: '_ProspectStoreBase.hasMore'))
      .value;
  Computed<bool>? _$hasMoreContactedComputed;

  @override
  bool get hasMoreContacted => (_$hasMoreContactedComputed ??= Computed<bool>(
          () => super.hasMoreContacted,
          name: '_ProspectStoreBase.hasMoreContacted'))
      .value;

  late final _$prospectsAtom =
      Atom(name: '_ProspectStoreBase.prospects', context: context);

  @override
  ObservableList<ProspectEntity> get prospects {
    _$prospectsAtom.reportRead();
    return super.prospects;
  }

  @override
  set prospects(ObservableList<ProspectEntity> value) {
    _$prospectsAtom.reportWrite(value, super.prospects, () {
      super.prospects = value;
    });
  }

  late final _$contactedProspectsAtom =
      Atom(name: '_ProspectStoreBase.contactedProspects', context: context);

  @override
  ObservableList<ProspectEntity> get contactedProspects {
    _$contactedProspectsAtom.reportRead();
    return super.contactedProspects;
  }

  @override
  set contactedProspects(ObservableList<ProspectEntity> value) {
    _$contactedProspectsAtom.reportWrite(value, super.contactedProspects, () {
      super.contactedProspects = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_ProspectStoreBase.isLoading', context: context);

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

  late final _$isLoadingContactedAtom =
      Atom(name: '_ProspectStoreBase.isLoadingContacted', context: context);

  @override
  bool get isLoadingContacted {
    _$isLoadingContactedAtom.reportRead();
    return super.isLoadingContacted;
  }

  @override
  set isLoadingContacted(bool value) {
    _$isLoadingContactedAtom.reportWrite(value, super.isLoadingContacted, () {
      super.isLoadingContacted = value;
    });
  }

  late final _$isLoadingMoreAtom =
      Atom(name: '_ProspectStoreBase.isLoadingMore', context: context);

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

  late final _$isLoadingMoreContactedAtom =
      Atom(name: '_ProspectStoreBase.isLoadingMoreContacted', context: context);

  @override
  bool get isLoadingMoreContacted {
    _$isLoadingMoreContactedAtom.reportRead();
    return super.isLoadingMoreContacted;
  }

  @override
  set isLoadingMoreContacted(bool value) {
    _$isLoadingMoreContactedAtom
        .reportWrite(value, super.isLoadingMoreContacted, () {
      super.isLoadingMoreContacted = value;
    });
  }

  late final _$isMarkingContactedAtom =
      Atom(name: '_ProspectStoreBase.isMarkingContacted', context: context);

  @override
  bool get isMarkingContacted {
    _$isMarkingContactedAtom.reportRead();
    return super.isMarkingContacted;
  }

  @override
  set isMarkingContacted(bool value) {
    _$isMarkingContactedAtom.reportWrite(value, super.isMarkingContacted, () {
      super.isMarkingContacted = value;
    });
  }

  late final _$markingContactedIdAtom =
      Atom(name: '_ProspectStoreBase.markingContactedId', context: context);

  @override
  int? get markingContactedId {
    _$markingContactedIdAtom.reportRead();
    return super.markingContactedId;
  }

  @override
  set markingContactedId(int? value) {
    _$markingContactedIdAtom.reportWrite(value, super.markingContactedId, () {
      super.markingContactedId = value;
    });
  }

  late final _$errorAtom =
      Atom(name: '_ProspectStoreBase.error', context: context);

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
      Atom(name: '_ProspectStoreBase.currentPage', context: context);

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
      Atom(name: '_ProspectStoreBase.lastPage', context: context);

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

  late final _$currentPageContactedAtom =
      Atom(name: '_ProspectStoreBase.currentPageContacted', context: context);

  @override
  int get currentPageContacted {
    _$currentPageContactedAtom.reportRead();
    return super.currentPageContacted;
  }

  @override
  set currentPageContacted(int value) {
    _$currentPageContactedAtom.reportWrite(value, super.currentPageContacted,
        () {
      super.currentPageContacted = value;
    });
  }

  late final _$lastPageContactedAtom =
      Atom(name: '_ProspectStoreBase.lastPageContacted', context: context);

  @override
  int get lastPageContacted {
    _$lastPageContactedAtom.reportRead();
    return super.lastPageContacted;
  }

  @override
  set lastPageContacted(int value) {
    _$lastPageContactedAtom.reportWrite(value, super.lastPageContacted, () {
      super.lastPageContacted = value;
    });
  }

  late final _$totalProspectsAtom =
      Atom(name: '_ProspectStoreBase.totalProspects', context: context);

  @override
  int get totalProspects {
    _$totalProspectsAtom.reportRead();
    return super.totalProspects;
  }

  @override
  set totalProspects(int value) {
    _$totalProspectsAtom.reportWrite(value, super.totalProspects, () {
      super.totalProspects = value;
    });
  }

  late final _$totalContactedProspectsAtom = Atom(
      name: '_ProspectStoreBase.totalContactedProspects', context: context);

  @override
  int get totalContactedProspects {
    _$totalContactedProspectsAtom.reportRead();
    return super.totalContactedProspects;
  }

  @override
  set totalContactedProspects(int value) {
    _$totalContactedProspectsAtom
        .reportWrite(value, super.totalContactedProspects, () {
      super.totalContactedProspects = value;
    });
  }

  late final _$loadProspectsAsyncAction =
      AsyncAction('_ProspectStoreBase.loadProspects', context: context);

  @override
  Future<void> loadProspects() {
    return _$loadProspectsAsyncAction.run(() => super.loadProspects());
  }

  late final _$loadMoreProspectsAsyncAction =
      AsyncAction('_ProspectStoreBase.loadMoreProspects', context: context);

  @override
  Future<void> loadMoreProspects() {
    return _$loadMoreProspectsAsyncAction.run(() => super.loadMoreProspects());
  }

  late final _$loadContactedProspectsAsyncAction = AsyncAction(
      '_ProspectStoreBase.loadContactedProspects',
      context: context);

  @override
  Future<void> loadContactedProspects() {
    return _$loadContactedProspectsAsyncAction
        .run(() => super.loadContactedProspects());
  }

  late final _$loadMoreContactedProspectsAsyncAction = AsyncAction(
      '_ProspectStoreBase.loadMoreContactedProspects',
      context: context);

  @override
  Future<void> loadMoreContactedProspects() {
    return _$loadMoreContactedProspectsAsyncAction
        .run(() => super.loadMoreContactedProspects());
  }

  late final _$markAsContactedAsyncAction =
      AsyncAction('_ProspectStoreBase.markAsContacted', context: context);

  @override
  Future<bool> markAsContacted(int prospectId) {
    return _$markAsContactedAsyncAction
        .run(() => super.markAsContacted(prospectId));
  }

  late final _$_ProspectStoreBaseActionController =
      ActionController(name: '_ProspectStoreBase', context: context);

  @override
  void clearError() {
    final _$actionInfo = _$_ProspectStoreBaseActionController.startAction(
        name: '_ProspectStoreBase.clearError');
    try {
      return super.clearError();
    } finally {
      _$_ProspectStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
prospects: ${prospects},
contactedProspects: ${contactedProspects},
isLoading: ${isLoading},
isLoadingContacted: ${isLoadingContacted},
isLoadingMore: ${isLoadingMore},
isLoadingMoreContacted: ${isLoadingMoreContacted},
isMarkingContacted: ${isMarkingContacted},
markingContactedId: ${markingContactedId},
error: ${error},
currentPage: ${currentPage},
lastPage: ${lastPage},
currentPageContacted: ${currentPageContacted},
lastPageContacted: ${lastPageContacted},
totalProspects: ${totalProspects},
totalContactedProspects: ${totalContactedProspects},
hasMore: ${hasMore},
hasMoreContacted: ${hasMoreContacted}
    ''';
  }
}
