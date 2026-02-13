import '../../domain/entities/subcategory_entity.dart';
import 'product_dto.dart';
import 'statistics_dto.dart';

class SubcategoryDTO {
  final int id;
  final String nome;
  final int ordem;
  final List<ProductDTO> produtos;
  final StatisticsDTO? estatisticas;

  SubcategoryDTO({
    required this.id,
    required this.nome,
    required this.ordem,
    required this.produtos,
    this.estatisticas,
  });

  factory SubcategoryDTO.fromJson(Map<String, dynamic> json) {
    try {
      final int id = json['id'] as int;
      final String nome = json['nome'] as String;
      final int ordem = json['ordem'] as int? ?? 0;

      final List<ProductDTO> produtos = [];
      if (json['produtos'] != null && json['produtos'] is List) {
        final prodList = json['produtos'] as List<dynamic>;

        for (int i = 0; i < prodList.length; i++) {
          try {
            final prodJson = prodList[i] as Map<String, dynamic>;
            final prod = ProductDTO.fromJson(prodJson);
            produtos.add(prod);
          } catch (e) {
            rethrow;
          }
        }
      }

      StatisticsDTO? estatisticas;
      if (json['estatisticas'] != null) {
        estatisticas = StatisticsDTO.fromJson(
            json['estatisticas'] as Map<String, dynamic>);
      }

      return SubcategoryDTO(
        id: id,
        nome: nome,
        ordem: ordem,
        produtos: produtos,
        estatisticas: estatisticas,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  SubcategoryEntity toEntity() {
    return SubcategoryEntity(
      id: id,
      nome: nome,
      ordem: ordem,
      produtos: produtos.map((p) => p.toEntity()).toList(),
      estatisticas: estatisticas?.toEntity(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'ordem': ordem,
      'produtos': produtos.map((p) => p.toJson()).toList(),
      if (estatisticas != null) 'estatisticas': estatisticas!.toJson(),
    };
  }

  factory SubcategoryDTO.fromEntity(SubcategoryEntity entity) {
    return SubcategoryDTO(
      id: entity.id,
      nome: entity.nome,
      ordem: entity.ordem,
      produtos: entity.produtos.map((p) => ProductDTO.fromEntity(p)).toList(),
      estatisticas: entity.estatisticas != null
          ? StatisticsDTO.fromEntity(entity.estatisticas!)
          : null,
    );
  }
}
