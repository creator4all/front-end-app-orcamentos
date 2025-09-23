// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subcategory_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SubcategoryStore on _SubcategoryStore, Store {
  late final _$subcategoriasAtom =
      Atom(name: '_SubcategoryStore.subcategorias', context: context);

  @override
  List<SubcategoryDto> get subcategorias {
    _$subcategoriasAtom.reportRead();
    return super.subcategorias;
  }

  @override
  set subcategorias(List<SubcategoryDto> value) {
    _$subcategoriasAtom.reportWrite(value, super.subcategorias, () {
      super.subcategorias = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_SubcategoryStore.isLoading', context: context);

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

  late final _$errorAtom =
      Atom(name: '_SubcategoryStore.error', context: context);

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

  late final _$lastCategoriaIdAtom =
      Atom(name: '_SubcategoryStore.lastCategoriaId', context: context);

  @override
  int? get lastCategoriaId {
    _$lastCategoriaIdAtom.reportRead();
    return super.lastCategoriaId;
  }

  @override
  set lastCategoriaId(int? value) {
    _$lastCategoriaIdAtom.reportWrite(value, super.lastCategoriaId, () {
      super.lastCategoriaId = value;
    });
  }

  late final _$fetchSubcategoriasAsyncAction =
      AsyncAction('_SubcategoryStore.fetchSubcategorias', context: context);

  @override
  Future<void> fetchSubcategorias(int categoriaId) {
    return _$fetchSubcategoriasAsyncAction
        .run(() => super.fetchSubcategorias(categoriaId));
  }

  @override
  String toString() {
    return '''
subcategorias: ${subcategorias},
isLoading: ${isLoading},
error: ${error},
lastCategoriaId: ${lastCategoriaId}
    ''';
  }
}
