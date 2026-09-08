import '../../../../../shared/domain/value_objects/fractional_order.dart';
import '../../domain/entities/category_entity.dart';

class CategoryDto {
  final int id;
  final String nome;
  final bool status;
  final FractionalOrder ordem;

  CategoryDto({
    required this.id,
    required this.nome,
    required this.status,
    required this.ordem,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    final statusValue = json['cat_status'];
    final status = statusValue == 1 || statusValue == true;

    return CategoryDto(
      id: json['cat_categoriaId'] as int,
      nome: json['cat_nome'] as String? ?? '',
      status: status,
      ordem: FractionalOrder.parse(json['cat_ordem']),
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
