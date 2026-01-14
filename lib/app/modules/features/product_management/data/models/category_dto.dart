import '../../domain/entities/category_entity.dart';

/// DTO para parsing JSON de categorias
class CategoryDto {
  final int id;
  final String nome;
  final bool status;
  final int ordem;

  CategoryDto({
    required this.id,
    required this.nome,
    required this.status,
    required this.ordem,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    // API retorna status como int (1 = true, 0 = false)
    final statusValue = json['cat_status'];
    final status = statusValue == 1 || statusValue == true;

    return CategoryDto(
      id: json['cat_categoriaId'] as int,
      nome: json['cat_nome'] as String? ?? '',
      status: status,
      ordem: json['cat_ordem'] as int? ?? 0,
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      nome: nome,
      status: status,
      ordem: ordem,
    );
  }
}
