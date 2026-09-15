import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/category_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_escolar_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/indicador_etapa_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/product_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/subcategory_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/services/product_calculation_service.dart';
import 'package:multimidiaapp/app/shared/domain/value_objects/fractional_order.dart';

const _censo = CensoEscolarEntity(
  cidadeId: 1,
  cidadeNome: 'Cidade',
  grupos: [],
  valoresPorEtapa: {
    'ef1ano': 100.0,
    'ef2ano': 50.0,
    'ef1anoP': 10.0,
    'ef2anoP': 5.0,
  },
);

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

List<CategoryEntity> _categorias(List<ProductEntity> produtos) => [
      CategoryEntity(
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
      ),
    ];

void main() {
  const service = ProductCalculationService();

  group('ProductCalculationService.calcularQuantidadeServico', () {
    test('soma só vinculados marcados e usa a quantidade manual do vinculado',
        () {
      final produtos = [
        _produto(1, etapas: ['ef1ano']),
        _produto(2, etapas: ['ef2ano'], selecionado: false),
        _produto(3,
            tipoProduto: 'livro', quantidadeManual: true, quantidade: 40),
      ];
      final servico = _produto(9,
          tipoProduto: 'servico', percent: 0.5, relacionados: [1, 2, 3]);

      // floor((100 + 40) × 0,5)
      expect(service.calcularQuantidadeServico(servico, produtos, _censo), 70);
    });

    test('arredonda depois de somar as horas fixas', () {
      final produtos = [_produto(1, quantidadeManual: true, quantidade: 33)];

      expect(
        service.calcularQuantidadeServico(
          _produto(9,
              tipoProduto: 'servico',
              percent: 0.5,
              horasFixas: 0.4,
              relacionados: [1]),
          produtos,
          _censo,
        ),
        16,
      );
      expect(
        service.calcularQuantidadeServico(
          _produto(9,
              tipoProduto: 'servico',
              percent: 0.5,
              horasFixas: 0.5,
              relacionados: [1]),
          produtos,
          _censo,
        ),
        17,
      );
    });

    test('usa as horas fixas quando não há vinculado marcado', () {
      final produtos = [
        _produto(1, etapas: ['ef1ano'], selecionado: false)
      ];

      expect(
        service.calcularQuantidadeServico(
          _produto(9,
              tipoProduto: 'servico', horasFixas: 240, relacionados: [1]),
          produtos,
          _censo,
        ),
        240,
      );
      expect(
        service.calcularQuantidadeServico(
          _produto(9, tipoProduto: 'servico', horasFixas: 240),
          produtos,
          null,
        ),
        240,
      );
    });

    test('sem censo e sem vinculado marcado devolve floor(horasFixas)', () {
      final produtos = [
        _produto(1, etapas: ['ef1ano'], selecionado: false)
      ];

      // Com relacionados mas nenhum marcado: floor(horasFixas) mesmo sem censo.
      expect(
        service.calcularQuantidadeServico(
          _produto(9,
              tipoProduto: 'servico', horasFixas: 240.7, relacionados: [1]),
          produtos,
          null,
        ),
        240,
      );
    });

    test('sem censo com todos vinculados manuais calcula normalmente', () {
      final produtos = [
        _produto(1, quantidadeManual: true, quantidade: 30),
        _produto(2, quantidadeManual: true, quantidade: 10),
      ];

      // floor((30 + 10) × 0,5 + 0) = 20
      expect(
        service.calcularQuantidadeServico(
          _produto(9,
              tipoProduto: 'servico', percent: 0.5, relacionados: [1, 2]),
          produtos,
          null,
        ),
        20,
      );
    });

    test('sem censo com vinculado automático mantém a quantidade atual', () {
      final servico = _produto(9,
          tipoProduto: 'servico',
          percent: 0.5,
          quantidade: 7,
          relacionados: [1]);
      final produtos = [
        _produto(1, etapas: ['ef1ano']), // automático, depende de censo
      ];

      // Vinculado automático sem censo: conservador, não inventa valor.
      expect(
        service.calcularQuantidadeServico(servico, produtos, null),
        7,
      );
    });

    test('sem censo com misto manual/automático mantém a quantidade atual', () {
      final servico = _produto(9,
          tipoProduto: 'servico',
          percent: 0.5,
          quantidade: 12,
          relacionados: [1, 2]);
      final produtos = [
        _produto(1, quantidadeManual: true, quantidade: 30),
        _produto(2, etapas: ['ef1ano']), // automático, depende de censo
      ];

      // Não calcula total parcial silenciosamente: mantém a quantidade atual.
      expect(
        service.calcularQuantidadeServico(servico, produtos, null),
        12,
      );
    });

    test('percentual explicitamente zero usa só as horas fixas', () {
      final produtos = [
        _produto(1, quantidadeManual: true, quantidade: 100),
      ];

      // floor(100 × 0 + 15) = 15
      expect(
        service.calcularQuantidadeServico(
          _produto(9,
              tipoProduto: 'servico',
              percent: 0,
              horasFixas: 15,
              relacionados: [1]),
          produtos,
          _censo,
        ),
        15,
      );
    });
  });

  group('ProductCalculationService.recalcularServicosDependentes', () {
    test('recalcula só serviços marcados e não manuais que dependem do produto',
        () {
      final categorias = _categorias([
        _produto(1, etapas: ['ef1ano']),
        _produto(9,
            tipoProduto: 'servico',
            percent: 0.5,
            quantidade: 1,
            relacionados: [1]),
        _produto(10,
            tipoProduto: 'servico',
            percent: 0.5,
            quantidade: 1,
            quantidadeManual: true,
            relacionados: [1]),
        _produto(11,
            tipoProduto: 'servico',
            percent: 0.5,
            quantidade: 1,
            selecionado: false,
            relacionados: [1]),
        _produto(12,
            tipoProduto: 'servico',
            percent: 0.5,
            quantidade: 1,
            relacionados: [2]),
      ]);

      final resultado =
          service.recalcularServicosDependentes(categorias, _censo, {1});
      final quantidades = {
        for (final p in resultado.first.subcategorias.first.produtos)
          p.id: p.quantidade,
      };

      expect(quantidades[9], 50);
      expect(quantidades[10], 1);
      expect(quantidades[11], 1);
      expect(quantidades[12], 1);
    });

    test('devolve a mesma lista quando nenhum serviço depende do produto', () {
      final categorias = _categorias([
        _produto(1, etapas: ['ef1ano'])
      ]);

      expect(
        identical(
          service.recalcularServicosDependentes(categorias, _censo, {1}),
          categorias,
        ),
        isTrue,
      );
    });

    test('preserva serviços manuais e desmarcados', () {
      final categorias = _categorias([
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
      ]);

      final resultado =
          service.recalcularServicosDependentes(categorias, _censo, {1});
      final produtos = resultado.first.subcategorias.first.produtos;
      final byId = {for (final p in produtos) p.id: p};

      // Manual preserva a quantidade digitada.
      expect((byId[9]!).quantidade, 42);
      expect((byId[9]!).quantidadeManual, isTrue);
      // Desmarcado não é recalculado.
      expect((byId[10]!).quantidade, 5);
      expect((byId[10]!).selecionado, isFalse);
    });

    test('não muta a entrada e preserva referências dos objetos não alterados',
        () {
      final categorias = _categorias([
        _produto(1, etapas: ['ef1ano']),
        _produto(9,
            tipoProduto: 'servico',
            percent: 0.5,
            quantidade: 1,
            relacionados: [1]),
        _produto(10, etapas: ['ef2ano']), // não depende do produto 1
      ]);

      final originalCat = categorias.first;
      final originalSub = originalCat.subcategorias.first;
      final originalProd1 = originalSub.produtos[0];
      final originalProd9 = originalSub.produtos[1];
      final originalProd10 = originalSub.produtos[2];

      final resultado =
          service.recalcularServicosDependentes(categorias, _censo, {1});
      final resultSub = resultado.first.subcategorias.first;
      final resultProdutos = resultSub.produtos;

      // A lista de entrada não foi mutada.
      expect(categorias.first, same(originalCat));
      expect(categorias.first.subcategorias.first, same(originalSub));
      expect(categorias.first.subcategorias.first.produtos[0],
          same(originalProd1));
      expect(categorias.first.subcategorias.first.produtos[1],
          same(originalProd9));
      expect(categorias.first.subcategorias.first.produtos[2],
          same(originalProd10));

      // O produto não alterado (10) preserva a mesma referência no resultado.
      final resultProd10 = resultProdutos.firstWhere((p) => p.id == 10);
      expect(resultProd10, same(originalProd10));

      // O produto vinculado não afetado (1) preserva a referência.
      final resultProd1 = resultProdutos.firstWhere((p) => p.id == 1);
      expect(resultProd1, same(originalProd1));

      // O serviço recalculado (9) recebeu nova instância com nova quantidade.
      final resultProd9 = resultProdutos.firstWhere((p) => p.id == 9);
      expect(identical(resultProd9, originalProd9), isFalse);
      expect(resultProd9.quantidade, 50);
    });
  });
}
