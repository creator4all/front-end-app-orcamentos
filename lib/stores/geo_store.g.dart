// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$GeoStore on _GeoStore, Store {
  late final _$isLoadingEstadosAtom =
      Atom(name: '_GeoStore.isLoadingEstados', context: context);

  @override
  bool get isLoadingEstados {
    _$isLoadingEstadosAtom.reportRead();
    return super.isLoadingEstados;
  }

  @override
  set isLoadingEstados(bool value) {
    _$isLoadingEstadosAtom.reportWrite(value, super.isLoadingEstados, () {
      super.isLoadingEstados = value;
    });
  }

  late final _$isLoadingCidadesAtom =
      Atom(name: '_GeoStore.isLoadingCidades', context: context);

  @override
  bool get isLoadingCidades {
    _$isLoadingCidadesAtom.reportRead();
    return super.isLoadingCidades;
  }

  @override
  set isLoadingCidades(bool value) {
    _$isLoadingCidadesAtom.reportWrite(value, super.isLoadingCidades, () {
      super.isLoadingCidades = value;
    });
  }

  late final _$errorAtom = Atom(name: '_GeoStore.error', context: context);

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

  late final _$estadosAtom = Atom(name: '_GeoStore.estados', context: context);

  @override
  ObservableList<EstadoEntity> get estados {
    _$estadosAtom.reportRead();
    return super.estados;
  }

  @override
  set estados(ObservableList<EstadoEntity> value) {
    _$estadosAtom.reportWrite(value, super.estados, () {
      super.estados = value;
    });
  }

  late final _$cidadesAtom = Atom(name: '_GeoStore.cidades', context: context);

  @override
  ObservableList<CidadeEntity> get cidades {
    _$cidadesAtom.reportRead();
    return super.cidades;
  }

  @override
  set cidades(ObservableList<CidadeEntity> value) {
    _$cidadesAtom.reportWrite(value, super.cidades, () {
      super.cidades = value;
    });
  }

  late final _$estadoSelecionadoAtom =
      Atom(name: '_GeoStore.estadoSelecionado', context: context);

  @override
  EstadoEntity? get estadoSelecionado {
    _$estadoSelecionadoAtom.reportRead();
    return super.estadoSelecionado;
  }

  @override
  set estadoSelecionado(EstadoEntity? value) {
    _$estadoSelecionadoAtom.reportWrite(value, super.estadoSelecionado, () {
      super.estadoSelecionado = value;
    });
  }

  late final _$cidadeSelecionadaAtom =
      Atom(name: '_GeoStore.cidadeSelecionada', context: context);

  @override
  CidadeEntity? get cidadeSelecionada {
    _$cidadeSelecionadaAtom.reportRead();
    return super.cidadeSelecionada;
  }

  @override
  set cidadeSelecionada(CidadeEntity? value) {
    _$cidadeSelecionadaAtom.reportWrite(value, super.cidadeSelecionada, () {
      super.cidadeSelecionada = value;
    });
  }

  late final _$carregarEstadosAsyncAction =
      AsyncAction('_GeoStore.carregarEstados', context: context);

  @override
  Future<void> carregarEstados() {
    return _$carregarEstadosAsyncAction.run(() => super.carregarEstados());
  }

  late final _$carregarCidadesAsyncAction =
      AsyncAction('_GeoStore.carregarCidades', context: context);

  @override
  Future<void> carregarCidades([int? estadoId]) {
    return _$carregarCidadesAsyncAction
        .run(() => super.carregarCidades(estadoId));
  }

  late final _$selecionarEstadoAsyncAction =
      AsyncAction('_GeoStore.selecionarEstado', context: context);

  @override
  Future<void> selecionarEstado(EstadoEntity? estado) {
    return _$selecionarEstadoAsyncAction
        .run(() => super.selecionarEstado(estado));
  }

  late final _$_GeoStoreActionController =
      ActionController(name: '_GeoStore', context: context);

  @override
  void selecionarCidade(CidadeEntity? c) {
    final _$actionInfo = _$_GeoStoreActionController.startAction(
        name: '_GeoStore.selecionarCidade');
    try {
      return super.selecionarCidade(c);
    } finally {
      _$_GeoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void limparSelecao() {
    final _$actionInfo = _$_GeoStoreActionController.startAction(
        name: '_GeoStore.limparSelecao');
    try {
      return super.limparSelecao();
    } finally {
      _$_GeoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoadingEstados: ${isLoadingEstados},
isLoadingCidades: ${isLoadingCidades},
error: ${error},
estados: ${estados},
cidades: ${cidades},
estadoSelecionado: ${estadoSelecionado},
cidadeSelecionada: ${cidadeSelecionada}
    ''';
  }
}
