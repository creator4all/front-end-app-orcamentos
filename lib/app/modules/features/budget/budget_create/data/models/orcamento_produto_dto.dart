import '../../domain/entities/orcamento_produto_entity.dart';
import 'produto_dto.dart';

/// DTO para OrcamentoProduto
class OrcamentoProdutoDto {
  final int id;
  final int orcamentoId;
  final int produtoId;
  final bool selecionado;
  final double quantidade;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProdutoDto produto;

  const OrcamentoProdutoDto({
    required this.id,
    required this.orcamentoId,
    required this.produtoId,
    required this.selecionado,
    required this.quantidade,
    required this.createdAt,
    required this.updatedAt,
    required this.produto,
  });

  factory OrcamentoProdutoDto.fromJson(Map<String, dynamic> json) {
    final produtoJson = json['produto'] as Map<String, dynamic>? ?? {};

    return OrcamentoProdutoDto(
      id: (json['op_id'] as num?)?.toInt() ?? 0,
      orcamentoId: (json['op_orcamento_id'] as num?)?.toInt() ?? 0,
      produtoId: (json['op_produto_id'] as num?)?.toInt() ?? 0,
      selecionado: json['op_selecionado'] as bool? ?? false,
      quantidade: double.tryParse(json['op_quantidade']?.toString() ?? '0') ?? 0.0,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
      produto: ProdutoDto.fromJson(produtoJson),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  OrcamentoProdutoEntity toEntity() {
    return OrcamentoProdutoEntity(
      id: id,
      orcamentoId: orcamentoId,
      produtoId: produtoId,
      selecionado: selecionado,
      quantidade: quantidade,
      createdAt: createdAt,
      updatedAt: updatedAt,
      produto: produto.toEntity(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'op_id': id,
      'op_orcamento_id': orcamentoId,
      'op_produto_id': produtoId,
      'op_selecionado': selecionado,
      'op_quantidade': quantidade.toString(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'produto': produto.toJson(),
    };
  }
}
