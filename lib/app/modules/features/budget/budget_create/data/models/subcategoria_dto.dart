import '../../domain/entities/subcategoria_entity.dart';
import 'categoria_dto.dart';

class SubcategoriaDto {
  final int id;
  final String nome;
  final int categoriaId;
  final CategoriaDto categoria;

  const SubcategoriaDto({
    required this.id,
    required this.nome,
    required this.categoriaId,
    required this.categoria,
  });

  factory SubcategoriaDto.fromJson(Map<String, dynamic> json) {
    final categoriaJson = json['categoria'] as Map<String, dynamic>? ?? {};
    
    return SubcategoriaDto(
      id: (json['sub_subcategoriasId'] as num?)?.toInt() ?? 0,
      nome: json['sub_name'] as String? ?? '',
      categoriaId: (json['cat_categoria_id'] as num?)?.toInt() ?? 0,
      categoria: CategoriaDto.fromJson(categoriaJson),
    );
  }

  SubcategoriaEntity toEntity() {
    return SubcategoriaEntity(
      id: id,
      nome: nome,
      categoriaId: categoriaId,
      categoria: categoria.toEntity(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sub_subcategoriasId': id,
      'sub_name': nome,
      'cat_categoria_id': categoriaId,
      'categoria': categoria.toJson(),
    };
  }
}
