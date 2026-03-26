import 'package:equatable/equatable.dart';

import '../../budget_config/domain/entities/product_entity.dart';
import 'indicador_produto_update_dto.dart';

class ProductSelectionUpdateDto extends Equatable {
  final int productId;
  final bool selecionado;
  final double quantidade;
  final String tipoProduto;
  final List<IndicadorProdutoUpdateDto>? indicadores;
  final double? valor;

  const ProductSelectionUpdateDto({
    required this.productId,
    required this.selecionado,
    required this.quantidade,
    required this.tipoProduto,
    this.indicadores,
    this.valor,
  });

  bool get isServico {
    final tipo = tipoProduto.toLowerCase();
    return tipo == 'servico' || tipo == 'serviÃ§o';
  }

  factory ProductSelectionUpdateDto.fromEntity(ProductEntity entity) {
    final indicadoresDto = (entity.indicadoresEtapa.toList()
          ..sort(
              (a, b) => a.produtoIndicadorId.compareTo(b.produtoIndicadorId)))
        .map((ind) => IndicadorProdutoUpdateDto.fromEntity(ind))
        .toList();

    final valorAlterado = entity.hasValueOverride ? entity.valor : null;

    return ProductSelectionUpdateDto(
      productId: entity.id,
      selecionado: entity.selecionado,
      quantidade: entity.quantidade,
      tipoProduto: entity.tipoProduto,
      indicadores: indicadoresDto.isNotEmpty ? indicadoresDto : null,
      valor: valorAlterado,
    );
  }

  Map<String, dynamic> toJson() => {
        'produto_id': productId,
        'selecionado': selecionado,
        if (isServico) 'quantidade': quantidade,
        if (indicadores != null)
          'indicadores_etapa': indicadores!.map((i) => i.toJson()).toList(),
        if (valor != null) 'valor': valor,
      };

  Map<String, dynamic> toJsonForMultiCity() => {
        'produto_id': productId,
        'selecionado': selecionado,
        if (isServico) 'quantidade': quantidade,
        if (!isServico && indicadores != null && indicadores!.isNotEmpty)
          'indicadores_etapa': indicadores!.map((i) => i.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        productId,
        selecionado,
        quantidade,
        tipoProduto,
        indicadores,
        valor,
      ];

  @override
  String toString() =>
      'ProductSelectionUpdateDto(productId: $productId, selecionado: $selecionado, quantidade: $quantidade, tipoProduto: $tipoProduto, indicadores: ${indicadores?.length ?? 0}, valor: $valor)';
}
