import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/auth/domain/entities/user.dart';
import 'package:multimidiaapp/app/modules/features/auth/presentation/stores/auth_store.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/category_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/product_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/subcategory_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/services/budget_value_rules.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/services/censo_escolar_mapper.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/services/product_calculation_service.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/services/product_quantity_rules.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/usecases/get_census_data_usecase.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/domain/entities/budget_edit_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/domain/repositories/budget_edit_repository.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/domain/usecases/get_budget_for_edit_usecase.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/domain/usecases/update_budget_usecase.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/presentation/stores/budget_edit_store.dart';
import 'package:multimidiaapp/app/modules/features/budget/shared/errors/budget_failure.dart';
import 'package:multimidiaapp/app/shared/domain/value_objects/fractional_order.dart';

/// Falha se qualquer endpoint for acionado.
class _UnusedBudgetEditRepository implements BudgetEditRepository {
  int chamadas = 0;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    chamadas++;
    return super.noSuchMethod(invocation);
  }
}

class _FakeAuthStore implements AuthStore {
  @override
  User? get currentUser => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetBudgetForEditUseCase implements GetBudgetForEditUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetCensusDataUseCase implements GetCensusDataUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ProductEntity _product(int id, {required double valor, double quantidade = 1}) {
  return ProductEntity(
    id: id,
    codigo: 'P$id',
    solucao: 'Produto $id',
    tipo: 'Livro',
    ativo: true,
    valor: valor,
    indicacao: '',
    tipoProduto: 'livro',
    ordem: FractionalOrder.zero,
    subcategoriaId: 1,
    selecionado: true,
    quantidade: quantidade,
    quantidadeManual: true,
    temOverride: false,
    valorOriginal: valor,
    ativoOriginal: true,
    indicadoresEtapa: const [],
  );
}

CategoryEntity _category(List<ProductEntity> produtos) {
  return CategoryEntity(
    id: 1,
    nome: 'Categoria',
    ordem: FractionalOrder.zero,
    expandido: false,
    subcategorias: [
      SubcategoryEntity(
        id: 1,
        nome: 'Subcategoria',
        ordem: FractionalOrder.zero,
        produtos: produtos,
      ),
    ],
  );
}

BudgetEditStore _store(_UnusedBudgetEditRepository repository) {
  final store = BudgetEditStore(
    getBudgetForEditUseCase: _FakeGetBudgetForEditUseCase(),
    updateBudgetUseCase: UpdateBudgetUseCase(repository),
    getCensusDataUseCase: _FakeGetCensusDataUseCase(),
    authStore: _FakeAuthStore(),
    calculationService: const ProductCalculationService(),
    censoEscolarMapper: const CensoEscolarMapper(),
  );
  store.validityDate = DateTime(2026, 10);
  store.budgetData = BudgetEditEntity(
    id: 55,
    name: 'projeto educacao 129',
    validityDays: 60,
    validityDate: DateTime(2026, 10),
    status: 'pendente',
    total: 100,
    userId: 4,
    cityIds: const [297, 299],
    products: const [],
    categoriesData: const <Map<String, dynamic>>[],
    multiCity: true,
  );
  return store;
}

void main() {
  group('BudgetEditStore limites de valor', () {
    test('bloqueia o salvamento quando o total ultrapassa o limite do servidor',
        () async {
      final repository = _UnusedBudgetEditRepository();
      final quantidadeMaxima = ProductQuantityRules.maxQuantity.toDouble();
      final store = _store(repository)
        ..categories.add(_category([
          for (var id = 1; id <= 6; id++)
            _product(
              id,
              valor: BudgetValueRules.maxUnitValue,
              quantidade: quantidadeMaxima,
            ),
        ]));

      final result = await store.saveBudgetWithDto();

      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, BudgetValueRules.totalExceededMessage);
        },
        (_) => fail('deveria ter falhado'),
      );
      expect(repository.chamadas, 0,
          reason: 'nenhum endpoint pode ser acionado com total inválido');
      expect(store.isSaving, isFalse);
      expect(store.error, BudgetValueRules.totalExceededMessage);
    });

    test('limita o valor unitário ao máximo aceito pelo servidor', () {
      final store = _store(_UnusedBudgetEditRepository())
        ..categories.add(_category([_product(1, valor: 10)]));

      store.updateProductValue(1, 16600000000000000);

      final produto = store.categories.first.subcategorias.first.produtos.first;
      expect(produto.valor, BudgetValueRules.maxUnitValue);
    });
  });
}
