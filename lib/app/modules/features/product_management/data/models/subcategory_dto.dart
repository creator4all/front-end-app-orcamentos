import '../../../../../shared/domain/value_objects/fractional_order.dart';
import '../../domain/entities/subcategory_entity.dart';

class SubcategoryDto {
  final int id;
  final String nome;
  final bool status;
  final FractionalOrder ordem;
  final int categoriaId;

  SubcategoryDto({
    required this.id,
    required this.nome,
    required this.status,
    required this.ordem,
    required this.categoriaId,
  });

  factory SubcategoryDto.fromJson(Map<String, dynamic> json) {
    final statusValue = json['sub_status'];
    final status = statusValue == 1 || statusValue == true;

    return SubcategoryDto(
      id: json['sub_subcategoriasId'] as int,
      nome: json['sub_name'] as String? ?? '',
      status: status,
      ordem: FractionalOrder.parse(json['sub_order']),
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
