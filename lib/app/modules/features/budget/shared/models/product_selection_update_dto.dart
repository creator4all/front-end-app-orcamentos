import 'package:equatable/equatable.dart';

import '../../budget_config/domain/entities/product_entity.dart';

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
///   "quantidade": 5
/// }
/// ```
class ProductSelectionUpdateDto extends Equatable {
  /// ID do produto
  final int productId;

  /// Se o produto está selecionado/marcado pelo usuário
  final bool selecionado;

  /// Quantidade do produto no orçamento
  final int quantidade;

  const ProductSelectionUpdateDto({
    required this.productId,
    required this.selecionado,
    required this.quantidade,
  });

  /// Factory para criar a partir de ProductEntity
  ///
  /// Facilita a conversão de entidades de domínio para DTOs
  ///
  /// Exemplo:
  /// ```dart
  /// final dto = ProductSelectionUpdateDto.fromEntity(productEntity);
  /// ```
  factory ProductSelectionUpdateDto.fromEntity(ProductEntity entity) {
    return ProductSelectionUpdateDto(
      productId: entity.id,
      selecionado: entity.selecionado,
      quantidade: entity.quantidade,
    );
  }

  /// Converte para Map para envio via API
  Map<String, dynamic> toJson() => {
        'produto_id': productId,
        'selecionado': selecionado,
        'quantidade': quantidade,
      };

  @override
  List<Object?> get props => [productId, selecionado, quantidade];

  @override
  String toString() =>
      'ProductSelectionUpdateDto(productId: $productId, selecionado: $selecionado, quantidade: $quantidade)';
}
