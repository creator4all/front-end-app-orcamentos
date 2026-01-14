import 'package:equatable/equatable.dart';

/// Produto relacionado (para produtos do tipo serviço)
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

/// Entidade completa do produto para configuração/edição
class ProductConfigEntity extends Equatable {
  final int id;
  final String codigo;
  final String solucao;
  final String indicacao;
  final String tipo; // mensal, anual, horas
  final double valor;
  final String tipoProduto; // servico, livro, tecnologia
  final String? isbn;
  final double? percent;
  final bool ativo;
  final bool status;
  final int ordem;
  final int subcategoriaId;
  final String? categoriaNome;
  final String? subcategoriaNome;

  /// Mapa de indicadores: chave é o nome (ex: "ef1ano"), valor é true/false
  final Map<String, bool> indicadores;

  /// Produtos relacionados (para serviços)
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

  /// Verifica se o produto é do tipo serviço
  bool get isServico => tipoProduto.toLowerCase() == 'servico';

  /// Verifica se o produto é do tipo livro
  bool get isLivro => tipoProduto.toLowerCase() == 'livro';

  /// Verifica se o produto é do tipo tecnologia
  bool get isTecnologia => tipoProduto.toLowerCase() == 'tecnologia';

  /// Cria uma cópia com valores alterados
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
