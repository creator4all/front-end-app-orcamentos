import '../../domain/entities/categoria_entity.dart';

/// DTO para Categoria
class CategoriaDto {
  final int id;
  final String nome;
  final int status;
  final int ordem;

  const CategoriaDto({
    required this.id,
    required this.nome,
    required this.status,
    required this.ordem,
  });

  factory CategoriaDto.fromJson(Map<String, dynamic> json) {
    return CategoriaDto(
      id: (json['cat_categoriaId'] as num?)?.toInt() ?? 0,
      nome: json['cat_nome'] as String? ?? '',
      status: (json['cat_status'] as num?)?.toInt() ?? 0,
      ordem: (json['cat_ordem'] as num?)?.toInt() ?? 0,
    );
  }

  CategoriaEntity toEntity() {
    return CategoriaEntity(
      id: id,
      nome: nome,
      status: status,
      ordem: ordem,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cat_categoriaId': id,
      'cat_nome': nome,
      'cat_status': status,
      'cat_ordem': ordem,
    };
  }
}
