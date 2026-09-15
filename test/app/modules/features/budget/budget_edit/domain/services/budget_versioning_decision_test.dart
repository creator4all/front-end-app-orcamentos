import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/category_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/indicador_etapa_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/product_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/subcategory_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/domain/services/budget_versioning_decision.dart';
import 'package:multimidiaapp/app/shared/domain/value_objects/fractional_order.dart';

ProductEntity _produto({
  int id = 1,
  bool selecionado = true,
  double quantidade = 1,
  bool quantidadeManual = false,
  double valor = 10,
  String? observacoes,
  Map<int, bool> indicadores = const {1: true},
}) {
  return ProductEntity(
    id: id,
    codigo: 'P$id',
    solucao: 'Produto',
    tipo: 'tecnologia',
    ativo: true,
    valor: valor,
    indicacao: '',
    tipoProduto: 'tecnologia',
    ordem: FractionalOrder.zero,
    subcategoriaId: 1,
    selecionado: selecionado,
    quantidade: quantidade,
    quantidadeManual: quantidadeManual,
    temOverride: false,
    observacoes: observacoes,
    valorOriginal: 10,
    ativoOriginal: true,
    indicadoresEtapa: [
      for (final entry in indicadores.entries)
        IndicadorEtapaEntity(
          produtoIndicadorId: entry.key,
          indicadorId: entry.key,
          indicadorNome: 'ef1ano',
          nomeEtapa: 'ef1ano',
          grupoId: 1,
          grupoNome: 'Etapas',
          selecionado: entry.value,
        ),
    ],
  );
}

void main() {
  group('BudgetVersioningDecision', () {
    test('detecta seleção de produto', () {
      final original = {
        _produto(selecionado: false).id:
            BudgetVersioningDecision.fromProduct(_produto(selecionado: false))
      };
      final current = {
        _produto(selecionado: true).id:
            BudgetVersioningDecision.fromProduct(_produto(selecionado: true))
      };

      expect(
        BudgetVersioningDecision.hasProductChanges(
          selectedIds: {1},
          originalSelectedIds: {},
          current: current,
          original: original,
        ),
        isTrue,
      );
    });

    test('produto inalterado não é mudança de produto', () {
      final snapshot = BudgetVersioningDecision.fromProduct(_produto());
      expect(
        BudgetVersioningDecision.hasProductChanges(
          selectedIds: {1},
          originalSelectedIds: {1},
          current: {1: snapshot},
          original: {1: snapshot},
        ),
        isFalse,
      );
    });

    test('withQuantidade altera só a quantidade de referência', () {
      final original = BudgetVersioningDecision.fromProduct(
        _produto(valor: 10, observacoes: 'obs', indicadores: {1: false}),
      );

      final atualizado = original.withQuantidade(7);

      expect(atualizado.quantidade, 7);
      expect(atualizado.valor, 10);
      expect(atualizado.observacoes, 'obs');
      expect(atualizado.indicadores, {1: false});
      expect(atualizado.selecionado, original.selecionado);
      expect(atualizado.quantidadeManual, original.quantidadeManual);
    });

    test('desfazer indicador não é mudança', () {
      final produto = _produto(indicadores: {1: true, 2: false});
      final snapshot = BudgetVersioningDecision.fromProduct(produto);

      expect(
        BudgetVersioningDecision.hasProductChanges(
          selectedIds: {1},
          originalSelectedIds: {1},
          current: {1: snapshot},
          original: {1: snapshot},
        ),
        isFalse,
      );
    });

    test('observação alterada é mudança de produto', () {
      expect(
        BudgetVersioningDecision.hasProductChanges(
          selectedIds: {1},
          originalSelectedIds: {1},
          current: {
            1: BudgetVersioningDecision.fromProduct(
                _produto(observacoes: 'nova'))
          },
          original: {1: BudgetVersioningDecision.fromProduct(_produto())},
        ),
        isTrue,
      );
    });

    test('monta snapshots a partir das categorias', () {
      final categories = [
        CategoryEntity(
          id: 1,
          nome: 'Cat',
          ordem: FractionalOrder.zero,
          expandido: false,
          subcategorias: [
            SubcategoryEntity(
              id: 1,
              nome: 'Sub',
              ordem: FractionalOrder.zero,
              produtos: [_produto(id: 9, quantidade: 4)],
            ),
          ],
        ),
      ];

      final snapshots =
          BudgetVersioningDecision.snapshotsFromCategories(categories);
      expect(snapshots[9]!.quantidade, 4);
    });
  });
}
