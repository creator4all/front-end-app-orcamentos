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
///   "quantidade": 5,           // Apenas para serviços
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

  /// Tipo do produto (livro, tecnologia, servico)
  /// Usado para determinar se quantidade deve ser enviada
  final String tipoProduto;

  /// Indicadores de etapa com status explícito (Opção B)
  /// Todos os indicadores são enviados com seu estado atual
  final List<IndicadorProdutoUpdateDto>? indicadores;

  /// Valor unitário alterado (null se não foi modificado)
  final double? valor;

  const ProductSelectionUpdateDto({
    required this.productId,
    required this.selecionado,
    required this.quantidade,
    required this.tipoProduto,
    this.indicadores,
    this.valor,
  });

  /// Verifica se é um serviço
  bool get isServico {
    final tipo = tipoProduto.toLowerCase();
    return tipo == 'servico' || tipo == 'serviço';
  }

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
    final indicadoresDto =
        entity.indicadoresEtapa
            .map((ind) => IndicadorProdutoUpdateDto.fromEntity(ind))
            .toList();

    // Valor apenas se foi alterado
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

  /// Converte para Map para envio via API
  ///
  /// - 'quantidade' é enviada APENAS para serviços
  /// - Para livros/tecnologias, o backend calcula a partir dos indicadores
  Map<String, dynamic> toJson() => {
    'produto_id': productId,
    'selecionado': selecionado,
    // ✅ Quantidade apenas para serviços
    if (isServico) 'quantidade': quantidade,
    if (indicadores != null)
      'indicadores_etapa': indicadores!.map((i) => i.toJson()).toList(),
    if (valor != null) 'valor': valor,
  };

  /// Converte para Map para envio via API no endpoint /versionar-multi-cidade
  ///
  /// Diferença do toJson():
  /// - Serviços: envia quantidade (sem indicadores)
  /// - Livros/Tecnologia: envia indicadores_etapa (sem quantidade)
  ///
  /// O backend não aceita quantidade + indicadores_etapa juntos
  Map<String, dynamic> toJsonForMultiCity() => {
    'produto_id': productId,
    'selecionado': selecionado,
    // ✅ Serviços: enviar quantidade
    if (isServico) 'quantidade': quantidade,
    // ✅ Demais tipos: enviar indicadores apenas se existirem
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
