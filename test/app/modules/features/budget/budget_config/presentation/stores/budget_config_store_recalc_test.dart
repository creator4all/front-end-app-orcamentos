import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/budget_detail_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/category_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_escolar_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_group_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_title_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/indicador_etapa_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/product_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/subcategory_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/repositories/budget_detail_repository.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/services/censo_escolar_mapper.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/services/product_calculation_service.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/usecases/calculate_totals_usecase.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/usecases/get_budget_detail_usecase.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/usecases/get_category_products_usecase.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/usecases/get_census_data_usecase.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/usecases/save_budget_usecase.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/usecases/toggle_category_usecase.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/presentation/stores/budget_config_store.dart';
import 'package:multimidiaapp/app/shared/domain/value_objects/fractional_order.dart';

/// Repository que falha se qualquer endpoint for acionado.
class _UnusedBudgetDetailRepository implements BudgetDetailRepository {
  int chamadas = 0;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    chamadas++;
    return super.noSuchMethod(invocation);
  }
}

class _FakeGetBudgetDetailUseCase implements GetBudgetDetailUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetCategoryProductsUseCase implements GetCategoryProductsUseCase {
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
  double valor = 10,
}) {
  return ProductEntity(
    id: id,
    codigo: 'P$id',
    solucao: 'Produto $id',
    tipo: tipoProduto,
    ativo: true,
    valor: valor,
    indicacao: '',
    tipoProduto: tipoProduto,
    ordem: FractionalOrder.zero,
    subcategoriaId: 1,
    selecionado: selecionado,
    quantidade: quantidade,
    quantidadeManual: quantidadeManual,
    temOverride: false,
    valorOriginal: valor,
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

/// Constrói os dados de cidade no formato esperado por
/// `_extractIndicesFromCityData`.
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

BudgetConfigStore _store() {
  final repository = _UnusedBudgetDetailRepository();
  return BudgetConfigStore(
    getBudgetDetailUseCase: _FakeGetBudgetDetailUseCase(),
    getCategoryProductsUseCase: _FakeGetCategoryProductsUseCase(),
    getCensusDataUseCase: _FakeGetCensusDataUseCase(),
    toggleCategoryUseCase: ToggleCategoryUseCase(),
    calculateTotalsUseCase: CalculateTotalsUseCase(),
    saveBudgetUseCase: SaveBudgetUseCase(repository),
    calculationService: const ProductCalculationService(),
    censoEscolarMapper: const CensoEscolarMapper(),
  );
}

void main() {
  group('BudgetConfigStore.updateProductFromModal', () {
    test('recalcula serviços dependentes ao alterar produto pelo modal', () {
      final store = _store();
      store.censoEscolar = _censoFromValores(1, 'Cidade', {
        'ef1ano': 100.0,
        'ef2ano': 50.0,
      });
      store.categories.add(_category([
        _produto(1, etapas: ['ef1ano']),
        _produto(9,
            tipoProduto: 'servico',
            percent: 0.5,
            quantidade: 1,
            relacionados: [1]),
      ]));

      // Simula o modal devolvendo o produto 1 com mais uma etapa.
      final updatedProduct = _produto(1, etapas: ['ef1ano', 'ef2ano']);
      store.updateProductFromModal(updatedProduct);

      final produtos = store.categories.first.subcategorias.first.produtos;
      final servico = produtos.firstWhere((p) => p.id == 9);

      // floor((100 + 50) × 0,5) = 75
      expect(servico.quantidade, 75);
    });

    test('preserva serviço manual e não recalcula desmarcado', () {
      final store = _store();
      store.censoEscolar = _censoFromValores(1, 'Cidade', {
        'ef1ano': 100.0,
      });
      store.categories.add(_category([
        _produto(1, etapas: ['ef1ano']),
        _produto(9,
            tipoProduto: 'servico',
            percent: 0.5,
            quantidade: 42,
            quantidadeManual: true,
            relacionados: [1]),
        _produto(10,
            tipoProduto: 'servico',
            percent: 0.5,
            quantidade: 5,
            selecionado: false,
            relacionados: [1]),
      ]));

      store.updateProductFromModal(_produto(1, etapas: ['ef1ano']));

      final produtos = store.categories.first.subcategorias.first.produtos;
      final manual = produtos.firstWhere((p) => p.id == 9);
      final desmarcado = produtos.firstWhere((p) => p.id == 10);

      expect(manual.quantidade, 42);
      expect(manual.quantidadeManual, isTrue);
      expect(desmarcado.quantidade, 5);
      expect(desmarcado.selecionado, isFalse);
    });
  });

  group('BudgetConfigStore.updateCensoEscolar multi-cidade', () {
    test('preserva o censo agregado das demais cidades ao atualizar uma cidade',
        () {
      final store = _store();
      final cityA =
          _cityData(10, 'Cidade A', valores: {'ef1ano': 100.0, 'ef2ano': 50.0});
      final cityB =
          _cityData(20, 'Cidade B', valores: {'ef1ano': 200.0, 'ef2ano': 30.0});

      store.budgetDetail = BudgetDetailEntity(
        id: 1,
        validityDays: 30,
        status: 'pendente',
        total: 0,
        userId: 1,
        cityIds: const [10, 20],
        products: const [],
        categoryStates: const {},
        categories: const [],
        citiesData: [cityA, cityB],
        multiCity: true,
        censoAgregado: const {'ef1ano': 300.0, 'ef2ano': 80.0},
      );
      store.censoEscolar = _censoFromValores(0, 'Agregado', {
        'ef1ano': 300.0,
        'ef2ano': 80.0,
      });

      // Atualiza só a cidade A com novos valores.
      final updatedCenso = _censoFromValores(10, 'Cidade A', {
        'ef1ano': 150.0,
        'ef2ano': 50.0,
      });
      store.updateCensoEscolar(updatedCenso);

      // censoEscolar deve ser o agregado: A(150+50) + B(200+30) = 350+80.
      expect(store.censoEscolar!.cidadeId, 0);
      expect(store.censoEscolar!.cidadeNome, 'Agregado');
      expect(store.censoEscolar!.valoresPorEtapa['ef1ano'], 350);
      expect(store.censoEscolar!.valoresPorEtapa['ef2ano'], 80);

      // A cidade B não foi alterada no budgetDetail.
      final cities = store.budgetDetail!.citiesData;
      expect(cities.length, 2);
      final cityBData = cities.firstWhere((c) => c['id'] == 20);
      final cityBIndices = cityBData['indices'] as List;
      final ef1anoB = cityBIndices.firstWhere(
        (i) => (i as Map<String, dynamic>)['nome_etapa'] == 'ef1ano',
      );
      expect(ef1anoB['valor'], 200);
    });
  });

  group('BudgetConfigStore.updateCensoEscolar cidade única', () {
    test('não agrega quando há apenas uma cidade', () {
      final store = _store();
      final cityA = _cityData(10, 'Cidade A', valores: {'ef1ano': 100.0});

      store.budgetDetail = BudgetDetailEntity(
        id: 1,
        validityDays: 30,
        status: 'pendente',
        total: 0,
        userId: 1,
        cityIds: const [10],
        products: const [],
        categoryStates: const {},
        categories: const [],
        citiesData: [cityA],
        multiCity: false,
        censoAgregado: const {'ef1ano': 100.0},
      );
      store.censoEscolar = _censoFromValores(10, 'Cidade A', {
        'ef1ano': 100.0,
      });

      final updatedCenso = _censoFromValores(10, 'Cidade A', {
        'ef1ano': 250.0,
      });
      store.updateCensoEscolar(updatedCenso);

      // Cidade única: censoEscolar é o da própria cidade, não agregado.
      expect(store.censoEscolar!.cidadeId, 10);
      expect(store.censoEscolar!.cidadeNome, 'Cidade A');
      expect(store.censoEscolar!.valoresPorEtapa['ef1ano'], 250);
    });
  });

  group('BudgetConfigStore.reloadProductsAfterCensusEdit', () {
    test(
        'recalcula quantidades após salvar censo usando o censo agregado '
        'em multi-cidade', () {
      final store = _store();
      final cityA = _cityData(10, 'Cidade A', valores: {'ef1ano': 100.0});
      final cityB = _cityData(20, 'Cidade B', valores: {'ef1ano': 200.0});

      store.budgetDetail = BudgetDetailEntity(
        id: 1,
        validityDays: 30,
        status: 'pendente',
        total: 0,
        userId: 1,
        cityIds: const [10, 20],
        products: const [],
        categoryStates: const {},
        categories: const [],
        citiesData: [cityA, cityB],
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
      store.reloadProductsAfterCensusEdit();

      final produto = store.categories.first.subcategorias.first.produtos.first;
      expect(produto.quantidade, 350);
    });
  });
}
