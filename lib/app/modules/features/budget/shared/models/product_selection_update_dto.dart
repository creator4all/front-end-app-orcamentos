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
  final String? observacoes;
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
    this.observacoes,
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
      indicadores: changedIndicadores,
      valor: entity.valor,
      observacoes: entity.observacoes,
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

    final temIndicadores =
        entity.indicadoresEtapa.any((ind) => ind.produtoIndicadorId > 0);

    // O preço efetivo vai sempre: comparar com `valorOriginal` (catálogo
    // atual) omitiria um preço digitado igual ao catálogo, e a API manteria
    // o valor da origem.
    return ProductSelectionUpdateDto(
      productId: entity.id,
      selecionado: entity.selecionado,
      quantidade: entity.quantidade,
      quantidadeManual: entity.quantidadeManual,
      tipoProduto: entity.tipoProduto,
      indicadores: temIndicadores ? indicadoresDto : null,
      valor: entity.valor,
      observacoes: entity.observacoes,
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
        if (indicadores != null)
          'indicadores_etapa': indicadores!.map((i) => i.toJson()).toList(),
        if (valor != null) 'valor': valor,
        if (observacoes != null) 'observacoes': observacoes,
      };

  Map<String, dynamic> toJson() => isDelta
      ? toJsonDelta()
      : {
          'produto_id': productId,
          'selecionado': selecionado,
          if (isServico || quantidadeManual) 'quantidade': quantidade,
          'quantidade_manual': quantidadeManual,
          if (indicadores != null)
            'indicadores_etapa': indicadores!.map((i) => i.toJson()).toList(),
          if (valor != null) 'valor': valor,
          if (observacoes != null) 'observacoes': observacoes,
        };

  Map<String, dynamic> toJsonForMultiCity() => {
        'produto_id': productId,
        'selecionado': selecionado,
        if (isServico || quantidadeManual) 'quantidade': quantidade,
        'quantidade_manual': quantidadeManual,
        if (!isServico && indicadores != null)
          'indicadores_etapa': indicadores!.map((i) => i.toJson()).toList(),
        if (valor != null) 'valor': valor,
        if (observacoes != null) 'observacoes': observacoes,
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
        observacoes,
      ];

  @override
  String toString() =>
      'ProductSelectionUpdateDto(productId: $productId, selecionado: $selecionado, quantidade: $quantidade, tipoProduto: $tipoProduto, indicadores: ${indicadores?.length ?? 0}, valor: $valor)';
}
