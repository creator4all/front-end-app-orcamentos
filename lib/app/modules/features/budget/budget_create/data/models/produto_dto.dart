import '../../domain/entities/produto_entity.dart';
import 'indicador_etapa_dto.dart';
import 'subcategoria_dto.dart';

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

  const ProdutoDto({
    required this.id,
    required this.status,
    required this.valor,
    required this.subcategoriaId,
    required this.solucao,
    required this.indicacao,
    required this.indicadores,
    required this.subcategoria,
  });

  factory ProdutoDto.fromJson(Map<String, dynamic> json) {
    // Parse indicadores array
    final indicadoresArray = json['indicadores'] as List? ?? [];
    final indicadores = indicadoresArray
        .map((item) => IndicadorEtapaDto.fromJson(item as Map<String, dynamic>))
        .toList();

    // Parse subcategoria
    final subcategoriaJson = json['subcategoria'] as Map<String, dynamic>? ?? {};

    return ProdutoDto(
      id: (json['pro_produtosId'] as num?)?.toInt() ?? 0,
      status: json['pro_status'] as bool? ?? false,
      valor: double.tryParse(json['pro_valor']?.toString() ?? '0') ?? 0.0,
      subcategoriaId: (json['pro_subcategoria_id'] as num?)?.toInt() ?? 0,
      solucao: json['pro_solucao'] as String? ?? '',
      indicacao: json['pro_indicacao'] as String? ?? '',
      indicadores: indicadores,
      subcategoria: SubcategoriaDto.fromJson(subcategoriaJson),
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
      'pro_produtosId': id,
      'pro_status': status,
      'pro_valor': valor.toString(),
      'pro_subcategoria_id': subcategoriaId,
      'pro_solucao': solucao,
      'pro_indicacao': indicacao,
      'indicadores': indicadores.map((dto) => dto.toJson()).toList(),
      'subcategoria': subcategoria.toJson(),
    };
  }
}
