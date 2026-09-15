import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/auth/domain/entities/user.dart';
import 'package:multimidiaapp/app/modules/features/auth/presentation/stores/auth_store.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/category_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/product_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/subcategory_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/services/censo_escolar_mapper.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/services/product_calculation_service.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/usecases/get_census_data_usecase.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/domain/entities/budget_edit_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/domain/repositories/budget_edit_repository.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/domain/usecases/get_budget_for_edit_usecase.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/domain/usecases/update_budget_usecase.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/presentation/stores/budget_edit_store.dart';
import 'package:multimidiaapp/app/modules/features/budget/shared/errors/budget_failure.dart';
import 'package:multimidiaapp/app/modules/features/budget/shared/models/budget_update_dto.dart';
import 'package:multimidiaapp/app/shared/domain/value_objects/fractional_order.dart';

/// Registra qual endpoint de versionamento foi acionado e com que payload.
class _RecordingBudgetEditRepository implements BudgetEditRepository {
  final List<String> chamadas = [];
  Map<String, dynamic>? payloadEnviado;

  @override
  Future<Either<BudgetFailure, BudgetEditEntity>> versionBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  }) async {
    chamadas.add('versionar');
    payloadEnviado = updateData.toJson();
    return Right(_entity(cityIds: const [299]));
  }

  @override
  Future<Either<BudgetFailure, BudgetEditEntity>>
      versionMultiCityBudgetWithDto({
    required int budgetId,
    required BudgetUpdateDto updateData,
  }) async {
    chamadas.add('versionar-multi-cidade');
    payloadEnviado = updateData.toJsonForMultiCity();
    return Right(_entity(cityIds: const [297, 299, 300], multiCity: true));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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

BudgetEditEntity _entity({
  required List<int> cityIds,
  bool? multiCity,
}) {
  return BudgetEditEntity(
    id: 3,
    name: 'projeto',
    validityDays: 60,
    validityDate: DateTime(2026, 10),
    status: 'pendente',
    total: 100,
    userId: 1,
    cityIds: cityIds,
    products: const [],
    categoriesData: const <Map<String, dynamic>>[],
    multiCity: multiCity,
  );
}

CategoryEntity _categoriaComProduto() {
  return const CategoryEntity(
    id: 1,
    nome: 'Cat',
    ordem: FractionalOrder.zero,
    expandido: false,
    subcategorias: [
      SubcategoryEntity(
        id: 1,
        nome: 'Sub',
        ordem: FractionalOrder.zero,
        produtos: [
          ProductEntity(
            id: 5,
            codigo: 'P5',
            solucao: 'Produto',
            tipo: 'tecnologia',
            ativo: true,
            valor: 10,
            indicacao: '',
            tipoProduto: 'tecnologia',
            ordem: FractionalOrder.zero,
            subcategoriaId: 1,
            selecionado: true,
            quantidade: 1,
            temOverride: false,
            valorOriginal: 10,
            ativoOriginal: true,
            indicadoresEtapa: [],
          ),
        ],
      ),
    ],
  );
}

BudgetEditStore _store(_RecordingBudgetEditRepository repository) {
  final store = BudgetEditStore(
    getBudgetForEditUseCase: _FakeGetBudgetForEditUseCase(),
    updateBudgetUseCase: UpdateBudgetUseCase(repository),
    getCensusDataUseCase: _FakeGetCensusDataUseCase(),
    authStore: _FakeAuthStore(),
    calculationService: const ProductCalculationService(),
    censoEscolarMapper: const CensoEscolarMapper(),
  );
  store.validityDate = DateTime(2026, 10);
  return store;
}

void main() {
  group('BudgetEditStore.saveBudgetWithDto', () {
    test('versiona pelo endpoint multi-cidade e não envia orc_cidade_id',
        () async {
      final repository = _RecordingBudgetEditRepository();
      final store = _store(repository)
        ..budgetData = _entity(cityIds: const [297, 299, 300], multiCity: true);

      final result = await store.saveBudgetWithDto();

      expect(result.isRight(), isTrue);
      expect(repository.chamadas, ['versionar-multi-cidade']);
      expect(repository.payloadEnviado!['cidades'], [
        {'cidade_id': 297},
        {'cidade_id': 299},
        {'cidade_id': 300},
      ]);
      expect(repository.payloadEnviado!.containsKey('orc_cidade_id'), isFalse);
    });

    test('usa o endpoint multi-cidade mesmo com uma única cidade vinculada',
        () async {
      final repository = _RecordingBudgetEditRepository();
      final store = _store(repository)
        ..budgetData = _entity(cityIds: const [297], multiCity: true);

      await store.saveBudgetWithDto();

      expect(repository.chamadas, ['versionar-multi-cidade']);
      expect(repository.payloadEnviado!.containsKey('orc_cidade_id'), isFalse);
    });

    test('versiona pelo endpoint legado quando o orçamento é de cidade única',
        () async {
      final repository = _RecordingBudgetEditRepository();
      final store = _store(repository)
        ..budgetData = _entity(cityIds: const [299], multiCity: false);

      await store.saveBudgetWithDto();

      expect(repository.chamadas, ['versionar']);
      expect(repository.payloadEnviado!['orc_cidade_id'], 299);
    });

    test('bloqueia o versionamento quando o contexto de cidades está vazio',
        () async {
      final repository = _RecordingBudgetEditRepository();
      final store = _store(repository)..budgetData = _entity(cityIds: const []);

      final result = await store.saveBudgetWithDto();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('deveria ter falhado'),
      );
      expect(repository.chamadas, isEmpty,
          reason: 'nenhum endpoint de versionamento pode ser acionado');
      expect(store.isSaving, isFalse);
      expect(store.error, isNotNull);
    });

    test('só metadados: envia os produtos inalterados para a API decidir',
        () async {
      final repository = _RecordingBudgetEditRepository();
      final store = _store(repository)
        ..budgetData = _entity(cityIds: const [299], multiCity: false);
      store.categories.add(_categoriaComProduto());
      store.selectedProductIds.add(5);

      store.setStatus('aprovado');
      await store.saveBudgetWithDto();

      expect(repository.chamadas, ['versionar']);
      expect(repository.payloadEnviado!['orc_status'], 'aprovado');
      final produtos = repository.payloadEnviado!['produtos'] as List<dynamic>;
      expect(produtos, hasLength(1));
      expect(produtos.single['valor'], 10);
    });

    test('um segundo salvar sem mudança continua enviando os produtos',
        () async {
      final repository = _RecordingBudgetEditRepository();
      final store = _store(repository)
        ..budgetData = _entity(cityIds: const [297, 299], multiCity: true);
      store.categories.add(_categoriaComProduto());
      store.selectedProductIds.add(5);

      await store.saveBudgetWithDto();
      repository.chamadas.clear();
      await store.saveBudgetWithDto();

      expect(repository.chamadas, ['versionar-multi-cidade']);
      expect(repository.payloadEnviado!['produtos'], hasLength(1));
      expect(store.hasChanges, isFalse);
      expect(store.budgetData!.id, 3);
    });

    test('não dispara um segundo salvar enquanto isSaving está ativo',
        () async {
      final repository = _RecordingBudgetEditRepository();
      final store = _store(repository)
        ..budgetData = _entity(cityIds: const [299], multiCity: false)
        ..isSaving = true;

      final result = await store.saveBudgetWithDto();

      expect(result.isLeft(), isTrue);
      expect(repository.chamadas, isEmpty);
    });

    test('edição de preço sobrevive ao recálculo do censo salvo', () async {
      final repository = _RecordingBudgetEditRepository();
      final store = _store(repository)
        ..budgetData = _entity(cityIds: const [299], multiCity: false);
      store.categories.add(_categoriaComProduto());
      store.selectedProductIds.add(5);

      // O primeiro salvamento com sucesso define a referência original.
      await store.saveBudgetWithDto();
      expect(store.hasChanges, isFalse);

      store.updateProductValue(5, 25);
      await store.reloadProductsAfterCensusEdit();

      expect(store.hasChanges, isTrue);

      await store.saveBudgetWithDto();

      final produtos = repository.payloadEnviado!['produtos'] as List<dynamic>;
      expect(produtos, hasLength(1));
      expect(produtos.single['produto_id'], 5);
      expect(produtos.single['valor'], 25);
    });

    test('selecionar produto envia a lista de produtos no payload', () async {
      final repository = _RecordingBudgetEditRepository();
      final store = _store(repository)
        ..budgetData = _entity(cityIds: const [299], multiCity: false);
      store.categories.add(_categoriaComProduto());
      store.selectedProductIds.add(5);

      await store.saveBudgetWithDto();

      expect(repository.chamadas, ['versionar']);
      final produtos = repository.payloadEnviado!['produtos'] as List<dynamic>;
      expect(produtos, isNotEmpty);
      expect(produtos.first['produto_id'], 5);
      expect(produtos.first['selecionado'], isTrue);
    });
  });
}
