class ProductDto {
  final int id;
  final String nome;
  final double? valor;
  final String? codigo;
  final int? subcategoriaId;
  final String? tipo;
  final String? isbn;
  final String? indicacao;

  ProductDto({
    required this.id,
    required this.nome,
    this.valor,
    this.codigo,
    this.subcategoriaId,
    this.tipo,
    this.isbn,
    this.indicacao,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    final rawValor = json['valor'] ?? json['pro_valor'];
    final double? valor = rawValor is num
        ? rawValor.toDouble()
        : double.tryParse('${rawValor ?? ''}');
    return ProductDto(
      id: (json['id'] ?? json['pro_produtosId']) as int,
      nome: (json['nome'] ?? json['pro_solucao'] ?? json['titulo']) as String,
      valor: valor,
      codigo: json['codigo']?.toString() ?? json['pro_codigo']?.toString(),
      subcategoriaId: json['pro_subcategoria_id'] as int?,
      tipo: json['tipo']?.toString() ??
          json['pro_tipo']?.toString() ??
          json['pro_tipo_produto']?.toString(),
      isbn: json['isbn']?.toString() ?? json['pro_isbn']?.toString(),
      indicacao:
          json['indicacao']?.toString() ?? json['pro_indicacao']?.toString(),
    );
  }
}
