import 'package:equatable/equatable.dart';

import '../../budget_config/domain/entities/product_entity.dart';
import 'indicador_produto_update_dto.dart';

class ProductSelectionUpdateDto extends Equatable {
  final int productId;
  final bool selecionado;
  final double quantidade;
  final bool quantidadeManual;
  final String tipoProduto;
  final List<IndicadorProdutoUpdateDto>? indicadores;
  final double? valor;
  final bool? selecionadoChanged;
  final bool? quantidadeChanged;
  final bool? valorChanged;
  final bool isDelta;

  const ProductSelectionUpdateDto({
    required this.productId,
    required this.selecionado,
    required this.quantidade,
    this.quantidadeManual = false,
    required this.tipoProduto,
    this.indicadores,
    this.valor,
    this.selecionadoChanged,
    this.quantidadeChanged,
    this.valorChanged,
    this.isDelta = false,
  });

  bool get isServico {
    final tipo = tipoProduto.toLowerCase();
    return tipo == 'servico' || tipo == 'serviÃ§o';
  }

  /// Factory para criar um DTO de delta (field-level): apenas os campos
  /// efetivamente alterados em relação ao snapshot inicial serão serializados.
  /// `produto_id` é sempre incluído.
  factory ProductSelectionUpdateDto.delta({
    required ProductEntity entity,
    required bool selecionadoChanged,
    required bool quantidadeChanged,
    required bool valorChanged,
    required Set<int> changedIndicatorIds,
  }) {
    final changedIndicadores = changedIndicatorIds.isEmpty
        ? null
        : (entity.indicadoresEtapa
                .where((ind) =>
                    ind.produtoIndicadorId > 0 &&
                    changedIndicatorIds.contains(ind.produtoIndicadorId))
                .toList()
              ..sort((a, b) =>
                  a.produtoIndicadorId.compareTo(b.produtoIndicadorId)))
            .map((ind) => IndicadorProdutoUpdateDto.fromEntity(ind))
            .toList();

    return ProductSelectionUpdateDto(
      productId: entity.id,
      selecionado: entity.selecionado,
      quantidade: entity.quantidade,
      quantidadeManual: entity.quantidadeManual,
      tipoProduto: entity.tipoProduto,
      indicadores: changedIndicadores != null && changedIndicadores.isEmpty
          ? null
          : changedIndicadores,
      valor: entity.valor,
      selecionadoChanged: selecionadoChanged,
      quantidadeChanged: quantidadeChanged,
      valorChanged: valorChanged,
      isDelta: true,
    );
  }

  factory ProductSelectionUpdateDto.fromEntity(ProductEntity entity) {
    final indicadoresDto = (entity.indicadoresEtapa
            .where((ind) => ind.produtoIndicadorId > 0)
            .toList()
          ..sort(
              (a, b) => a.produtoIndicadorId.compareTo(b.produtoIndicadorId)))
        .map((ind) => IndicadorProdutoUpdateDto.fromEntity(ind))
        .toList();

    final valorAlterado = entity.hasValueOverride ? entity.valor : null;

    return ProductSelectionUpdateDto(
      productId: entity.id,
      selecionado: entity.selecionado,
      quantidade: entity.quantidade,
      quantidadeManual: entity.quantidadeManual,
      tipoProduto: entity.tipoProduto,
      indicadores: indicadoresDto.isNotEmpty ? indicadoresDto : null,
      valor: valorAlterado,
    );
  }

  /// Modo delta: o produto só é incluído no payload quando teve alguma
  /// alteração, mas então enviamos sempre `produto_id`, `selecionado`,
  /// `quantidade` e `valor` (preservando os valores originais). Apenas os
  /// `indicadores_etapa` são filtrados (somente os alterados).
  Map<String, dynamic> toJsonDelta() => {
        'produto_id': productId,
        'selecionado': selecionado,
        'quantidade': quantidade,
        'quantidade_manual': quantidadeManual,
        if (indicadores != null && indicadores!.isNotEmpty)
          'indicadores_etapa': indicadores!.map((i) => i.toJson()).toList(),
        if (valor != null) 'valor': valor,
      };

  Map<String, dynamic> toJson() => isDelta
      ? toJsonDelta()
      : {
          'produto_id': productId,
          'selecionado': selecionado,
          if (isServico || quantidadeManual) 'quantidade': quantidade,
          'quantidade_manual': quantidadeManual,
          if (indicadores != null && indicadores!.isNotEmpty)
            'indicadores_etapa': indicadores!.map((i) => i.toJson()).toList(),
          if (valor != null) 'valor': valor,
        };

  Map<String, dynamic> toJsonForMultiCity() => {
        'produto_id': productId,
        'selecionado': selecionado,
        if (isServico || quantidadeManual) 'quantidade': quantidade,
        'quantidade_manual': quantidadeManual,
        if (!isServico && indicadores != null && indicadores!.isNotEmpty)
          'indicadores_etapa': indicadores!.map((i) => i.toJson()).toList(),
        if (valor != null) 'valor': valor,
      };

  @override
  List<Object?> get props => [
        productId,
        selecionado,
        quantidade,
        quantidadeManual,
        tipoProduto,
        indicadores,
        valor,
      ];

  @override
  String toString() =>
      'ProductSelectionUpdateDto(productId: $productId, selecionado: $selecionado, quantidade: $quantidade, tipoProduto: $tipoProduto, indicadores: ${indicadores?.length ?? 0}, valor: $valor)';
}
