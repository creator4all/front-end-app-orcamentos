import '../../domain/entities/produto_entity.dart';
import 'indicador_etapa_dto.dart';
import 'subcategoria_dto.dart';

class OrcamentoProdutoInfo {
  final int id;
  final double quantidade;
  final bool selecionado;

  const OrcamentoProdutoInfo({
    required this.id,
    required this.quantidade,
    required this.selecionado,
  });

  factory OrcamentoProdutoInfo.fromJson(Map<String, dynamic> json) {
    return OrcamentoProdutoInfo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      quantidade: double.tryParse(json['quantidade']?.toString() ?? '0') ?? 0.0,
      selecionado: json['selecionado'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantidade': quantidade.toString(),
      'selecionado': selecionado,
    };
  }
}

/// DTO para Produto
class ProdutoDto {
  final int id;
  final bool status;
  final double valor;
  final int subcategoriaId;
  final String solucao;
  final String indicacao;
  final List<IndicadorEtapaDto> indicadores;
  final SubcategoriaDto subcategoria;
  final OrcamentoProdutoInfo? orcamentoProduto;

  const ProdutoDto({
    required this.id,
    required this.status,
    required this.valor,
    required this.subcategoriaId,
    required this.solucao,
    required this.indicacao,
    required this.indicadores,
    required this.subcategoria,
    this.orcamentoProduto,
  });

  factory ProdutoDto.fromJson(Map<String, dynamic> json) {
    final indicadoresArray = json['indicadores'] as List? ?? [];
    final indicadores = indicadoresArray
        .map((item) => IndicadorEtapaDto.fromJson(item as Map<String, dynamic>))
        .toList();

    final subcategoriaJson =
        json['subcategoria'] as Map<String, dynamic>? ?? {};

    OrcamentoProdutoInfo? orcamentoProduto;
    final orcamentoProdutoJson =
        json['orcamento_produto'] as Map<String, dynamic>?;
    if (orcamentoProdutoJson != null) {
      orcamentoProduto = OrcamentoProdutoInfo.fromJson(orcamentoProdutoJson);
    }

    return ProdutoDto(
      id: (json['pro_produtosId'] as num?)?.toInt() ??
          (json['id'] as num?)?.toInt() ??
          0,
      status: json['pro_status'] as bool? ?? json['status'] as bool? ?? false,
      valor: (json['pro_valor'] as num?)?.toDouble() ??
          double.tryParse(json['pro_valor']?.toString() ?? '') ??
          (json['valor'] as num?)?.toDouble() ??
          0.0,
      subcategoriaId: (json['pro_subcategoria_id'] as num?)?.toInt() ?? 0,
      solucao:
          json['pro_solucao'] as String? ?? json['solucao'] as String? ?? '',
      indicacao: json['pro_indicacao'] as String? ??
          json['indicacao'] as String? ??
          '',
      indicadores: indicadores,
      subcategoria: SubcategoriaDto.fromJson(subcategoriaJson),
      orcamentoProduto: orcamentoProduto,
    );
  }

  ProdutoEntity toEntity() {
    return ProdutoEntity(
      id: id,
      status: status,
      valor: valor,
      subcategoriaId: subcategoriaId,
      solucao: solucao,
      indicacao: indicacao,
      indicadores: indicadores.map((dto) => dto.toEntity()).toList(),
      subcategoria: subcategoria.toEntity(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'valor': valor,
      'pro_subcategoria_id': subcategoriaId,
      'solucao': solucao,
      'indicacao': indicacao,
      'indicadores': indicadores.map((dto) => dto.toJson()).toList(),
      'subcategoria': subcategoria.toJson(),
      if (orcamentoProduto != null)
        'orcamento_produto': orcamentoProduto!.toJson(),
    };
  }
}
