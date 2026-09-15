import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/budget/shared/errors/budget_failure.dart';

import '../../budget_edit_test_fixture.dart';

void main() {
  late BudgetEditTestRepository repository;
  late BudgetEditTestStore store;

  setUp(() async {
    repository = BudgetEditTestRepository(editableBudget());
    store = BudgetEditTestStore(repository);
    await store.initialize(1);
  });

  test('carga e expansão não criam alterações pendentes', () {
    expect(store.hasChanges, isFalse);
    store.selectCategory(store.categories.first);
    store.selectSubcategory(store.categories.first.subcategorias.first);
    expect(store.hasChanges, isFalse);
    expect(repository.writes, 0);
  });

  final edits = <String, void Function(BudgetEditTestStore, bool)>{
    'modo manual': (s, undo) => s.setProductQuantityMode(2, !undo),
    'seleção': (s, undo) => s.toggleProduct(1, undo),
    'preço': (s, undo) => s.updateProductValue(1, undo ? 10 : 25),
    'quantidade manual': (s, undo) =>
        s.setProductManualQuantity(1, undo ? 10 : 25),
    'indicador': (s, undo) => s.toggleProductIndicator(1, 1),
    'observação': (s, undo) =>
        s.updateProductObservations(1, undo ? '' : 'Local'),
    'status': (s, undo) => s.setStatus(undo ? 'pendente' : 'aprovado'),
    'arquivamento': (s, undo) => s.setArchived(!undo),
  };

  for (final entry in edits.entries) {
    test('${entry.key}: detecta edição e desfazer restaura baseline', () {
      entry.value(store, false);
      expect(store.hasChanges, isTrue);
      entry.value(store, true);
      expect(store.hasChanges, isFalse);
      expect(repository.writes, 0);
    });
  }

  test('validade restaurada para data original dispensa aviso', () {
    final original = store.validityDate;
    store.setValidityDate(original!.add(const Duration(days: 2)));
    expect(store.hasChanges, isTrue);
    store.setValidityDate(original);
    expect(store.hasChanges, isFalse);
  });

  for (final multiCity in [false, true]) {
    test('censo salvo preserva quantidade manual pendente, multi=$multiCity',
        () async {
      repository.budget = editableBudget(multiCity: multiCity);
      await store.initialize(1);
      store.setProductManualQuantity(1, 25);
      store.updateCensoEscolar(changedCensus());
      await store.reloadProductsAfterCensusEdit();
      expect(store.product(1).quantidade, 25);
      expect(store.product(1).quantidadeManual, isTrue);
      expect(store.product(2).quantidade, 20);
      expect(store.hasChanges, isTrue);

      store.setProductManualQuantity(1, 10);
      expect(store.hasChanges, isFalse);
      expect(repository.reads, 2);
      expect(repository.writes, 0);
    });
  }

  test('recálculo após censo salvo sem edição local não gera aviso', () async {
    store.updateCensoEscolar(changedCensus());
    await store.reloadProductsAfterCensusEdit();
    expect(store.product(2).quantidade, 20);
    expect(store.hasChanges, isFalse);
  });

  test('falha ao salvar mantém alterações; sucesso limpa baseline', () async {
    store.updateProductValue(1, 25);
    repository.saveFailure = const ValidationFailure('Falha controlada');
    expect((await store.saveBudgetWithDto()).isLeft(), isTrue);
    expect(store.hasChanges, isTrue);
    expect(store.isSaving, isFalse);

    repository.saveFailure = null;
    expect((await store.saveBudgetWithDto()).isRight(), isTrue);
    expect(store.hasChanges, isFalse);
    expect(repository.writes, 2);
  });
}
