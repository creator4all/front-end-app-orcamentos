class CategoryDto {
  final int id;
  final String nome;

  CategoryDto({required this.id, required this.nome});

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      id: (json['cat_categoriaId'] ?? json['gru_gruposId'] ?? json['id'])
          as int,
      nome: (json['cat_nome'] ??
          json['gru_grupo_nome'] ??
          json['nome'] ??
          json['titulo']) as String,
    );
  }
}
