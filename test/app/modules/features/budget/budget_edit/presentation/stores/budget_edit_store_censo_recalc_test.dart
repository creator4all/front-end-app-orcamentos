import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/auth/domain/entities/user.dart';
import 'package:multimidiaapp/app/modules/features/auth/presentation/stores/auth_store.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/category_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_escolar_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_group_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_title_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/indicador_etapa_entity.dart';
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
import 'package:multimidiaapp/app/shared/domain/value_objects/fractional_order.dart';

/// Repository que falha se qualquer endpoint for acionado.
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

IndicadorEtapaEntity _indicador(String nomeEtapa) => IndicadorEtapaEntity(
      produtoIndicadorId: nomeEtapa.hashCode,
      indicadorId: 1,
      indicadorNome: nomeEtapa,
      nomeEtapa: nomeEtapa,
      grupoId: 1,
      grupoNome: 'Etapas',
      selecionado: true,
    );

ProductEntity _produto(
  int id, {
  String tipoProduto = 'tecnologia',
  List<String> etapas = const [],
  bool selecionado = true,
  bool quantidadeManual = false,
  double quantidade = 0,
  double? percent,
  double? horasFixas,
  List<int> relacionados = const [],
}) {
  return ProductEntity(
    id: id,
    codigo: 'P$id',
    solucao: 'Produto $id',
    tipo: tipoProduto,
    ativo: true,
    valor: 10,
    indicacao: '',
    tipoProduto: tipoProduto,
    ordem: FractionalOrder.zero,
    subcategoriaId: 1,
    selecionado: selecionado,
    quantidade: quantidade,
    quantidadeManual: quantidadeManual,
    temOverride: false,
    valorOriginal: 10,
    ativoOriginal: true,
    indicadoresEtapa: etapas.map(_indicador).toList(),
    percent: percent,
    horasFixas: horasFixas,
    produtosRelacionadosIds: relacionados,
  );
}

CategoryEntity _category(List<ProductEntity> produtos) => CategoryEntity(
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

Map<String, dynamic> _cityData(
  int id,
  String nome, {
  required Map<String, double> valores,
}) {
  return {
    'id': id,
    'nome': nome,
    'indices': [
      for (final entry in valores.entries)
        {
          'id': entry.key.hashCode,
          'nome_etapa': entry.key,
          'titulo': entry.key,
          'valor': entry.value,
          'grupo': {'id': 1, 'nome': 'Etapas'},
        },
    ],
  };
}

CensoEscolarEntity _censoFromValores(
  int cidadeId,
  String nome,
  Map<String, double> valores,
) {
  return CensoEscolarEntity(
    cidadeId: cidadeId,
    cidadeNome: nome,
    grupos: [
      CensoGroupEntity(
        id: 1,
        nome: 'Etapas',
        titulos: [
          for (final entry in valores.entries)
            CensoTitleEntity(
              id: entry.key.hashCode,
              nomeEtapa: entry.key,
              tituloExibicao: entry.key,
              valor: entry.value,
              isProfessores: entry.key.endsWith('P'),
              grupoId: 1,
            ),
        ],
      ),
    ],
    valoresPorEtapa: valores,
  );
}

BudgetEditStore _store() {
  final repository = _UnusedBudgetEditRepository();
  return BudgetEditStore(
    getBudgetForEditUseCase: _FakeGetBudgetForEditUseCase(),
    updateBudgetUseCase: UpdateBudgetUseCase(repository),
    getCensusDataUseCase: _FakeGetCensusDataUseCase(),
    authStore: _FakeAuthStore(),
    calculationService: const ProductCalculationService(),
    censoEscolarMapper: const CensoEscolarMapper(),
  );
}

void main() {
  group('BudgetEditStore.updateCensoEscolar multi-cidade', () {
    test('preserva o censo agregado das demais cidades ao atualizar uma cidade',
        () {
      final store = _store();
      final cityA =
          _cityData(10, 'Cidade A', valores: {'ef1ano': 100.0, 'ef2ano': 50.0});
      final cityB =
          _cityData(20, 'Cidade B', valores: {'ef1ano': 200.0, 'ef2ano': 30.0});

      store.budgetData = BudgetEditEntity(
        id: 1,
        validityDays: 30,
        status: 'pendente',
        total: 0,
        userId: 1,
        cityIds: const [10, 20],
        citiesDataRaw: [cityA, cityB],
        products: const [],
        categoriesData: const <Map<String, dynamic>>[],
        multiCity: true,
        censoAgregado: const {'ef1ano': 300.0, 'ef2ano': 80.0},
      );
      store.censoEscolar = _censoFromValores(0, 'Agregado', {
        'ef1ano': 300.0,
        'ef2ano': 80.0,
      });

      // Atualiza só a cidade A.
      store.updateCensoEscolar(
        _censoFromValores(10, 'Cidade A', {'ef1ano': 150.0, 'ef2ano': 50.0}),
      );

      // censoEscolar deve ser o agregado: A(150+50) + B(200+30) = 350+80.
      expect(store.censoEscolar!.cidadeId, 0);
      expect(store.censoEscolar!.cidadeNome, 'Agregado');
      expect(store.censoEscolar!.valoresPorEtapa['ef1ano'], 350);
      expect(store.censoEscolar!.valoresPorEtapa['ef2ano'], 80);

      // Cidade B inalterada.
      final cities = store.budgetData!.citiesDataRaw;
      expect(cities.length, 2);
      final cityBData = cities.firstWhere((c) => c['id'] == 20);
      final cityBIndices = cityBData['indices'] as List;
      final ef1anoB = cityBIndices.firstWhere(
        (i) => (i as Map<String, dynamic>)['nome_etapa'] == 'ef1ano',
      );
      expect(ef1anoB['valor'], 200);
    });
  });

  group('BudgetEditStore.updateCensoEscolar cidade única', () {
    test('não agrega quando há apenas uma cidade', () {
      final store = _store();
      final cityA = _cityData(10, 'Cidade A', valores: {'ef1ano': 100.0});

      store.budgetData = BudgetEditEntity(
        id: 1,
        validityDays: 30,
        status: 'pendente',
        total: 0,
        userId: 1,
        cityIds: const [10],
        citiesDataRaw: [cityA],
        products: const [],
        categoriesData: const <Map<String, dynamic>>[],
        multiCity: false,
        censoAgregado: const {'ef1ano': 100.0},
      );
      store.censoEscolar = _censoFromValores(10, 'Cidade A', {'ef1ano': 100.0});

      store.updateCensoEscolar(
        _censoFromValores(10, 'Cidade A', {'ef1ano': 250.0}),
      );

      // Cidade única: censoEscolar é o da própria cidade.
      expect(store.censoEscolar!.cidadeId, 10);
      expect(store.censoEscolar!.cidadeNome, 'Cidade A');
      expect(store.censoEscolar!.valoresPorEtapa['ef1ano'], 250);
    });
  });

  group('BudgetEditStore.reloadProductsAfterCensusEdit', () {
    test(
        'recalcula quantidades após salvar censo usando o censo agregado '
        'em multi-cidade', () async {
      final store = _store();
      final cityA = _cityData(10, 'Cidade A', valores: {'ef1ano': 100.0});
      final cityB = _cityData(20, 'Cidade B', valores: {'ef1ano': 200.0});

      store.budgetData = BudgetEditEntity(
        id: 1,
        validityDays: 30,
        status: 'pendente',
        total: 0,
        userId: 1,
        cityIds: const [10, 20],
        citiesDataRaw: [cityA, cityB],
        products: const [],
        categoriesData: const <Map<String, dynamic>>[],
        multiCity: true,
        censoAgregado: const {'ef1ano': 300.0},
      );
      store.categories.add(_category([
        _produto(1, etapas: ['ef1ano'], quantidade: 1),
      ]));

      // Atualiza o censo da cidade A.
      store.updateCensoEscolar(
        _censoFromValores(10, 'Cidade A', {'ef1ano': 150.0}),
      );

      // Após salvar, o recálculo usa o censo agregado (150 + 200 = 350).
      await store.reloadProductsAfterCensusEdit();

      final produto = store.categories.first.subcategorias.first.produtos.first;
      expect(produto.quantidade, 350);
    });
  });
}
