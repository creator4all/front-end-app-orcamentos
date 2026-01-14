import '../../domain/entities/subcategory_entity.dart';

/// DTO para parsing JSON de subcategorias
class SubcategoryDto {
  final int id;
  final String nome;
  final bool status;
  final int ordem;
  final int categoriaId;

  SubcategoryDto({
    required this.id,
    required this.nome,
    required this.status,
    required this.ordem,
    required this.categoriaId,
  });

  factory SubcategoryDto.fromJson(Map<String, dynamic> json) {
    // API retorna status como int (1 = true, 0 = false)
    final statusValue = json['sub_status'];
    final status = statusValue == 1 || statusValue == true;

    return SubcategoryDto(
      id: json['sub_subcategoriasId'] as int,
      nome: json['sub_name'] as String? ?? '',
      status: status,
      ordem: json['sub_order'] as int? ?? 0,
      categoriaId: json['cat_categoria_id'] as int? ?? 0,
    );
  }

  SubcategoryEntity toEntity() {
    return SubcategoryEntity(
      id: id,
      nome: nome,
      status: status,
      ordem: ordem,
      categoriaId: categoriaId,
    );
  }
}
