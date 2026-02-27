import 'package:equatable/equatable.dart';

class RelatedProductEntity extends Equatable {
  final int id;
  final String codigo;
  final String nome;

  const RelatedProductEntity({
    required this.id,
    required this.codigo,
    required this.nome,
  });

  @override
  List<Object?> get props => [id, codigo, nome];
}

class ProductConfigEntity extends Equatable {
  final int id;
  final String codigo;
  final String solucao;
  final String indicacao;
  final String tipo;
  final double valor;
  final String tipoProduto;
  final String? isbn;
  final double? percent;
  final bool ativo;
  final bool status;
  final int ordem;
  final int subcategoriaId;
  final String? categoriaNome;
  final String? subcategoriaNome;

  final Map<String, bool> indicadores;

  final List<RelatedProductEntity> produtosRelacionados;

  const ProductConfigEntity({
    required this.id,
    required this.codigo,
    required this.solucao,
    required this.indicacao,
    required this.tipo,
    required this.valor,
    required this.tipoProduto,
    this.isbn,
    this.percent,
    required this.ativo,
    required this.status,
    required this.ordem,
    required this.subcategoriaId,
    this.categoriaNome,
    this.subcategoriaNome,
    this.indicadores = const {},
    this.produtosRelacionados = const [],
  });

  bool get isServico => tipoProduto.toLowerCase() == 'servico';

  bool get isLivro => tipoProduto.toLowerCase() == 'livro';

  bool get isTecnologia => tipoProduto.toLowerCase() == 'tecnologia';

  ProductConfigEntity copyWith({
    int? id,
    String? codigo,
    String? solucao,
    String? indicacao,
    String? tipo,
    double? valor,
    String? tipoProduto,
    String? isbn,
    double? percent,
    bool? ativo,
    bool? status,
    int? ordem,
    int? subcategoriaId,
    String? categoriaNome,
    String? subcategoriaNome,
    Map<String, bool>? indicadores,
    List<RelatedProductEntity>? produtosRelacionados,
  }) {
    return ProductConfigEntity(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      solucao: solucao ?? this.solucao,
      indicacao: indicacao ?? this.indicacao,
      tipo: tipo ?? this.tipo,
      valor: valor ?? this.valor,
      tipoProduto: tipoProduto ?? this.tipoProduto,
      isbn: isbn ?? this.isbn,
      percent: percent ?? this.percent,
      ativo: ativo ?? this.ativo,
      status: status ?? this.status,
      ordem: ordem ?? this.ordem,
      subcategoriaId: subcategoriaId ?? this.subcategoriaId,
      categoriaNome: categoriaNome ?? this.categoriaNome,
      subcategoriaNome: subcategoriaNome ?? this.subcategoriaNome,
      indicadores: indicadores ?? this.indicadores,
      produtosRelacionados: produtosRelacionados ?? this.produtosRelacionados,
    );
  }

  @override
  List<Object?> get props => [
        id,
        codigo,
        solucao,
        indicacao,
        tipo,
        valor,
        tipoProduto,
        isbn,
        percent,
        ativo,
        status,
        ordem,
        subcategoriaId,
        categoriaNome,
        subcategoriaNome,
        indicadores,
        produtosRelacionados,
      ];
}
