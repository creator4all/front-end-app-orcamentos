// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CategoryStore on _CategoryStore, Store {
  late final _$categoriasAtom =
      Atom(name: '_CategoryStore.categorias', context: context);

  @override
  List<CategoryDto> get categorias {
    _$categoriasAtom.reportRead();
    return super.categorias;
  }

  @override
  set categorias(List<CategoryDto> value) {
    _$categoriasAtom.reportWrite(value, super.categorias, () {
      super.categorias = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_CategoryStore.isLoading', context: context);

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

  late final _$errorAtom = Atom(name: '_CategoryStore.error', context: context);

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

  late final _$fetchCategoriasAsyncAction =
      AsyncAction('_CategoryStore.fetchCategorias', context: context);

  @override
  Future<void> fetchCategorias() {
    return _$fetchCategoriasAsyncAction.run(() => super.fetchCategorias());
  }

  @override
  String toString() {
    return '''
categorias: ${categorias},
isLoading: ${isLoading},
error: ${error}
    ''';
  }
}
