import '../../domain/entities/category_entity.dart';
import 'statistics_dto.dart';
import 'subcategory_dto.dart';

class CategoryDTO {
  final int id;
  final String nome;
  final int ordem;
  final bool expandido;
  final List<SubcategoryDTO> subcategorias;
  final StatisticsDTO? estatisticas;

  CategoryDTO({
    required this.id,
    required this.nome,
    required this.ordem,
    required this.expandido,
    required this.subcategorias,
    this.estatisticas,
  });

  factory CategoryDTO.fromJson(Map<String, dynamic> json) {
    try {
      final int id = (json['cat_categoriaId'] as num?)?.toInt() ??
          (json['id'] as num?)?.toInt() ??
          0;
      final String nome =
          json['cat_nome'] as String? ?? json['nome'] as String? ?? '';
      final int ordem = (json['cat_ordem'] as num?)?.toInt() ??
          (json['ordem'] as num?)?.toInt() ??
          0;
      final bool expandido =
          json['cat_expandido'] as bool? ?? json['expandido'] as bool? ?? false;

      final List<SubcategoryDTO> subcategorias = [];
      if (json['subcategorias'] != null && json['subcategorias'] is List) {
        final subcatList = json['subcategorias'] as List<dynamic>;

        for (int i = 0; i < subcatList.length; i++) {
          try {
            final subcatJson = subcatList[i] as Map<String, dynamic>;
            final subcat = SubcategoryDTO.fromJson(subcatJson);
            subcategorias.add(subcat);
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

      return CategoryDTO(
        id: id,
        nome: nome,
        ordem: ordem,
        expandido: expandido,
        subcategorias: subcategorias,
        estatisticas: estatisticas,
      );
    } catch (e) {
      rethrow;
    }
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      nome: nome,
      ordem: ordem,
      expandido: expandido,
      subcategorias: subcategorias.map((s) => s.toEntity()).toList(),
      estatisticas: estatisticas?.toEntity(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'ordem': ordem,
      'expandido': expandido,
      'subcategorias': subcategorias.map((s) => s.toJson()).toList(),
      if (estatisticas != null) 'estatisticas': estatisticas!.toJson(),
    };
  }

  factory CategoryDTO.fromEntity(CategoryEntity entity) {
    return CategoryDTO(
      id: entity.id,
      nome: entity.nome,
      ordem: entity.ordem,
      expandido: entity.expandido,
      subcategorias: entity.subcategorias
          .map((s) => SubcategoryDTO.fromEntity(s))
          .toList(),
      estatisticas: entity.estatisticas != null
          ? StatisticsDTO.fromEntity(entity.estatisticas!)
          : null,
    );
  }
}
