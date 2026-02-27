import 'package:equatable/equatable.dart';

import '../../budget_config/domain/entities/indicador_etapa_entity.dart';

/// DTO para enviar estado de indicador de produto ao backend
///
/// Usado no endpoint `PUT /api/orcamentos/{id}` para atualizar
/// quais indicadores estão selecionados para cada produto.
///
/// Exemplo no JSON:
/// ```json
/// {
///   "produto_indicador_id": 12,
///   "selecionado": true
/// }
/// ```
class IndicadorProdutoUpdateDto extends Equatable {
  /// ID do relacionamento produto_indicador
  final int produtoIndicadorId;

  /// Se o indicador está selecionado para este produto
  final bool selecionado;

  const IndicadorProdutoUpdateDto({
    required this.produtoIndicadorId,
    required this.selecionado,
  });

  /// Factory para criar a partir de IndicadorEtapaEntity
  factory IndicadorProdutoUpdateDto.fromEntity(IndicadorEtapaEntity entity) {
    return IndicadorProdutoUpdateDto(
      produtoIndicadorId: entity.produtoIndicadorId,
      selecionado: entity.selecionado,
    );
  }

  /// Converte para Map para envio via API
  Map<String, dynamic> toJson() => {
        'produto_indicador_id': produtoIndicadorId,
        'selecionado': selecionado,
      };

  @override
  List<Object?> get props => [produtoIndicadorId, selecionado];

  @override
  String toString() =>
      'IndicadorProdutoUpdateDto(produtoIndicadorId: $produtoIndicadorId, selecionado: $selecionado)';
}
