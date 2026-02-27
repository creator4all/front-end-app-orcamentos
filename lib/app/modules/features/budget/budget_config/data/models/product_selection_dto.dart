import '../../domain/entities/product_selection_entity.dart';

/// DTO para produto selecionado
/// Responsável pela conversão JSON <-> Entity
class ProductSelectionDto {
  final int productId;
  final String name;
  final String category;
  final double price;
  final bool isSelected;
  final int? quantity;
  final String? observacoes;
  final List<ProductIndicatorDto> indicadoresEtapa;

  ProductSelectionDto({
    required this.productId,
    required this.name,
    required this.category,
    required this.price,
    required this.isSelected,
    this.quantity,
    this.observacoes,
    this.indicadoresEtapa = const [],
  });

  /// Cria DTO a partir do JSON da API
  factory ProductSelectionDto.fromJson(Map<String, dynamic> json) {
    final List<ProductIndicatorDto> indicadores = [];
    if (json['indicadores_etapa'] != null &&
        json['indicadores_etapa'] is List) {
      indicadores.addAll((json['indicadores_etapa'] as List)
          .map((i) => ProductIndicatorDto.fromJson(i as Map<String, dynamic>)));
    }

    return ProductSelectionDto(
      productId: json['id'] as int? ?? 0,
      name: (json['nome'] ?? '') as String,
      category: (json['categoria'] ?? '') as String,
      price: (json['preco'] as num? ?? 0.0).toDouble(),
      isSelected: json['selecionado'] as bool? ?? false,
      quantity: json['quantidade'] as int?,
      observacoes: (json['observacoes'] ?? '') as String,
      indicadoresEtapa: indicadores,
    );
  }

  /// Converte DTO para JSON (formato esperado pelo backend)
  Map<String, dynamic> toJson() {
    return {
      'produto_id': productId,
      'selecionado': isSelected,
      'quantidade': quantity ?? 0,
      'observacoes': observacoes ?? '',
      'indicadores_etapa': indicadoresEtapa.map((i) => i.toJson()).toList(),
    };
  }

  /// Converte DTO para Entity
  ProductSelectionEntity toEntity() {
    return ProductSelectionEntity(
      productId: productId,
      name: name,
      category: category,
      price: price,
      isSelected: isSelected,
      quantity: quantity,
    );
  }

  /// Cria DTO a partir de Entity
  factory ProductSelectionDto.fromEntity(ProductSelectionEntity entity) {
    return ProductSelectionDto(
      productId: entity.productId,
      name: entity.name,
      category: entity.category,
      price: entity.price,
      isSelected: entity.isSelected,
      quantity: entity.quantity,
    );
  }
}

/// DTO para indicador de etapa do produto
class ProductIndicatorDto {
  final int produtoIndicadorId;
  final bool selecionado;

  ProductIndicatorDto({
    required this.produtoIndicadorId,
    required this.selecionado,
  });

  factory ProductIndicatorDto.fromJson(Map<String, dynamic> json) {
    return ProductIndicatorDto(
      produtoIndicadorId: json['produto_indicador_id'] ?? 0,
      selecionado: json['selecionado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'produto_indicador_id': produtoIndicadorId,
      'selecionado': selecionado,
    };
  }
}
