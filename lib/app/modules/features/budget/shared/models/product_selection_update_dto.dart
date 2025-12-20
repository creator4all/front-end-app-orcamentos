import 'package:equatable/equatable.dart';

import '../../budget_config/domain/entities/product_entity.dart';
import 'indicador_produto_update_dto.dart';

/// DTO para atualização de seleção/quantidade de produto
///
/// Usado tanto por budget_config (salvar como pendente) quanto
/// budget_edit (editar orçamento existente) para enviar dados
/// de produtos ao endpoint PUT /api/orcamentos/{id}
///
/// Mapeia para o formato da API:
/// ```json
/// {
///   "produto_id": 123,
///   "selecionado": true,
///   "quantidade": 5,
///   "indicadores": [
///     {"produto_indicador_id": 12, "selecionado": true},
///     {"produto_indicador_id": 15, "selecionado": false}
///   ],
///   "valor": 89.90
/// }
/// ```
class ProductSelectionUpdateDto extends Equatable {
  /// ID do produto
  final int productId;

  /// Se o produto está selecionado/marcado pelo usuário
  final bool selecionado;

  /// Quantidade do produto no orçamento
  final int quantidade;

  /// Indicadores de etapa com status explícito (Opção B)
  /// Todos os indicadores são enviados com seu estado atual
  final List<IndicadorProdutoUpdateDto>? indicadores;

  /// Valor unitário alterado (null se não foi modificado)
  final double? valor;

  const ProductSelectionUpdateDto({
    required this.productId,
    required this.selecionado,
    required this.quantidade,
    this.indicadores,
    this.valor,
  });

  /// Factory para criar a partir de ProductEntity
  ///
  /// Facilita a conversão de entidades de domínio para DTOs
  /// Inclui todos os indicadores com status explícito e valor se alterado
  ///
  /// Exemplo:
  /// ```dart
  /// final dto = ProductSelectionUpdateDto.fromEntity(productEntity);
  /// ```
  factory ProductSelectionUpdateDto.fromEntity(ProductEntity entity) {
    // Todos os indicadores com status explícito
    final indicadoresDto = entity.indicadoresEtapa
        .map((ind) => IndicadorProdutoUpdateDto.fromEntity(ind))
        .toList();

    // Valor apenas se foi alterado
    final valorAlterado = entity.hasValueOverride ? entity.valor : null;

    return ProductSelectionUpdateDto(
      productId: entity.id,
      selecionado: entity.selecionado,
      quantidade: entity.quantidade,
      indicadores: indicadoresDto.isNotEmpty ? indicadoresDto : null,
      valor: valorAlterado,
    );
  }

  /// Converte para Map para envio via API
  Map<String, dynamic> toJson() => {
        'produto_id': productId,
        'selecionado': selecionado,
        'quantidade': quantidade,
        if (indicadores != null)
          'indicadores_etapa': indicadores!.map((i) => i.toJson()).toList(),
        if (valor != null) 'valor': valor,
      };

  @override
  List<Object?> get props => [productId, selecionado, quantidade, indicadores, valor];

  @override
  String toString() =>
      'ProductSelectionUpdateDto(productId: $productId, selecionado: $selecionado, quantidade: $quantidade, indicadores: ${indicadores?.length ?? 0}, valor: $valor)';
}
