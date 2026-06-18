import '../../domain/entities/categoria_entity.dart';

class CategoriaDto {
  final int id;
  final String nome;
  final int status;
  final int ordem;
  final bool expandido;

  const CategoriaDto({
    required this.id,
    required this.nome,
    required this.status,
    required this.ordem,
    this.expandido = true,
  });

  factory CategoriaDto.fromJson(Map<String, dynamic> json) {
    // cat_status can be bool or int from the API
    final rawStatus = json['cat_status'];
    int statusValue;
    if (rawStatus is bool) {
      statusValue = rawStatus ? 1 : 0;
    } else {
      statusValue = (rawStatus as num?)?.toInt() ?? 0;
    }

    return CategoriaDto(
      id: (json['cat_categoriaId'] as num?)?.toInt() ?? 0,
      nome: json['cat_nome'] as String? ?? '',
      status: statusValue,
      ordem: (json['cat_ordem'] as num?)?.toInt() ?? 0,
      expandido: json['cat_expandido'] as bool? ?? true,
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
      'cat_expandido': expandido,
    };
  }
}
