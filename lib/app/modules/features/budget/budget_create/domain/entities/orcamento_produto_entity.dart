import 'package:equatable/equatable.dart';

import 'produto_entity.dart';

/// Entidade que representa um Item do Orçamento (Produto selecionado)
class OrcamentoProdutoEntity extends Equatable {
  final int id;
  final int orcamentoId;
  final int produtoId;
  final bool selecionado;
  final double quantidade;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProdutoEntity produto;

  const OrcamentoProdutoEntity({
    required this.id,
    required this.orcamentoId,
    required this.produtoId,
    required this.selecionado,
    required this.quantidade,
    required this.createdAt,
    required this.updatedAt,
    required this.produto,
  });

  /// Calcula o total deste item (quantidade * valor unitário)
  double get total => quantidade * produto.valor;

  @override
  List<Object?> get props => [
        id,
        orcamentoId,
        produtoId,
        selecionado,
        quantidade,
        createdAt,
        updatedAt,
        produto,
      ];

  @override
  bool get stringify => true;
}
