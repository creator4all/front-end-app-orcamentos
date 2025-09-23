class SubcategoryDto {
  final int id;
  final String nome;
  final int? categoriaId;

  SubcategoryDto({required this.id, required this.nome, this.categoriaId});

  factory SubcategoryDto.fromJson(Map<String, dynamic> json) {
    return SubcategoryDto(
      id: (json['sub_subcategoriasId'] ?? json['id']) as int,
      nome: (json['sub_name'] ?? json['nome'] ?? json['titulo']) as String,
      categoriaId: (json['cat_categoria_id'] ?? json['categoria_id']) as int?,
    );
  }
}
