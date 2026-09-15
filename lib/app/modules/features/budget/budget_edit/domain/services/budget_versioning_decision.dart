import '../../../budget_config/domain/entities/category_entity.dart';
import '../../../budget_config/domain/entities/product_entity.dart';

class BudgetProductSnapshot {
  final bool selecionado;
  final double quantidade;
  final bool quantidadeManual;
  final double valor;
  final String? observacoes;
  final Map<int, bool> indicadores;

  const BudgetProductSnapshot({
    required this.selecionado,
    required this.quantidade,
    required this.quantidadeManual,
    required this.valor,
    required this.observacoes,
    required this.indicadores,
  });

  /// Atualiza só a quantidade de referência, preservando os demais campos
  /// originais (usado quando o recálculo vem do censo salvo, não do usuário).
  BudgetProductSnapshot withQuantidade(double quantidade) {
    return BudgetProductSnapshot(
      selecionado: selecionado,
      quantidade: quantidade,
      quantidadeManual: quantidadeManual,
      valor: valor,
      observacoes: observacoes,
      indicadores: indicadores,
    );
  }
}

/// Compara o formulário ao estado original persistido, sem HTTP ou widgets.
/// Indica alteração pendente na tela; quem decide se versiona é a API.
class BudgetVersioningDecision {
  static bool hasProductChanges({
    required Set<int> selectedIds,
    required Set<int> originalSelectedIds,
    required Map<int, BudgetProductSnapshot> current,
    required Map<int, BudgetProductSnapshot> original,
  }) {
    if (selectedIds.length != originalSelectedIds.length) {
      return true;
    }
    if (!selectedIds.containsAll(originalSelectedIds)) {
      return true;
    }

    for (final entry in current.entries) {
      final orig = original[entry.key];
      if (orig == null) {
        if (entry.value.selecionado) {
          return true;
        }
        continue;
      }

      final atual = entry.value;
      if (atual.selecionado != orig.selecionado) {
        return true;
      }
      if (atual.quantidade != orig.quantidade) {
        return true;
      }
      if (atual.quantidadeManual != orig.quantidadeManual) {
        return true;
      }
      if (atual.valor != orig.valor) {
        return true;
      }
      if ((atual.observacoes ?? '') != (orig.observacoes ?? '')) {
        return true;
      }

      final origIndicators = orig.indicadores;
      for (final indicator in atual.indicadores.entries) {
        if (origIndicators[indicator.key] != indicator.value) {
          return true;
        }
      }
    }

    return false;
  }

  static Map<int, BudgetProductSnapshot> snapshotsFromCategories(
    Iterable<CategoryEntity> categories,
  ) {
    final snapshots = <int, BudgetProductSnapshot>{};
    for (final category in categories) {
      for (final subcategory in category.subcategorias) {
        for (final product in subcategory.produtos) {
          snapshots[product.id] = fromProduct(product);
        }
      }
    }
    return snapshots;
  }

  static BudgetProductSnapshot fromProduct(ProductEntity product) {
    return BudgetProductSnapshot(
      selecionado: product.selecionado,
      quantidade: product.quantidade,
      quantidadeManual: product.quantidadeManual,
      valor: product.valor,
      observacoes: product.observacoes,
      indicadores: {
        for (final indicator in product.indicadoresEtapa)
          if (indicator.produtoIndicadorId > 0)
            indicator.produtoIndicadorId: indicator.selecionado,
      },
    );
  }
}
