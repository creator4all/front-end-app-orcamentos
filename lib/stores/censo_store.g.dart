// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'censo_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CensoStore on _CensoStore, Store {
  Computed<int>? _$totalEstudantesComputed;

  @override
  int get totalEstudantes =>
      (_$totalEstudantesComputed ??= Computed<int>(() => super.totalEstudantes,
              name: '_CensoStore.totalEstudantes'))
          .value;
  Computed<int>? _$quantidadeTurmasComputed;

  @override
  int get quantidadeTurmas => (_$quantidadeTurmasComputed ??= Computed<int>(
          () => super.quantidadeTurmas,
          name: '_CensoStore.quantidadeTurmas'))
      .value;
  Computed<List<CidadeIndice>>? _$indicesEtapaComputed;

  @override
  List<CidadeIndice> get indicesEtapa => (_$indicesEtapaComputed ??=
          Computed<List<CidadeIndice>>(() => super.indicesEtapa,
              name: '_CensoStore.indicesEtapa'))
      .value;

  late final _$isLoadingAtom =
      Atom(name: '_CensoStore.isLoading', context: context);

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

  late final _$errorAtom = Atom(name: '_CensoStore.error', context: context);

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

  late final _$censoAtom = Atom(name: '_CensoStore.censo', context: context);

  @override
  CensoData? get censo {
    _$censoAtom.reportRead();
    return super.censo;
  }

  @override
  set censo(CensoData? value) {
    _$censoAtom.reportWrite(value, super.censo, () {
      super.censo = value;
    });
  }

  late final _$carregarGruposCensoAsyncAction =
      AsyncAction('_CensoStore.carregarGruposCenso', context: context);

  @override
  Future<void> carregarGruposCenso() {
    return _$carregarGruposCensoAsyncAction
        .run(() => super.carregarGruposCenso());
  }

  late final _$carregarCensoPorCidadeAsyncAction =
      AsyncAction('_CensoStore.carregarCensoPorCidade', context: context);

  @override
  Future<void> carregarCensoPorCidade(int cidadeId) {
    return _$carregarCensoPorCidadeAsyncAction
        .run(() => super.carregarCensoPorCidade(cidadeId));
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
error: ${error},
censo: ${censo},
totalEstudantes: ${totalEstudantes},
quantidadeTurmas: ${quantidadeTurmas},
indicesEtapa: ${indicesEtapa}
    ''';
  }
}
