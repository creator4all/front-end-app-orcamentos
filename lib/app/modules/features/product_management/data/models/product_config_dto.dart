import '../../domain/entities/product_config_entity.dart';

class RelatedProductDto {
  final int id;
  final String codigo;
  final String nome;

  RelatedProductDto({
    required this.id,
    required this.codigo,
    required this.nome,
  });

  factory RelatedProductDto.fromJson(Map<String, dynamic> json) {
    return RelatedProductDto(
      id: json['id'] as int? ?? 0,
      codigo: json['codigo'] as String? ?? '',
      nome: json['nome'] as String? ?? '',
    );
  }

  RelatedProductEntity toEntity() {
    return RelatedProductEntity(
      id: id,
      codigo: codigo,
      nome: nome,
    );
  }
}

class ProductConfigDto {
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
  final List<RelatedProductDto> produtosRelacionados;

  ProductConfigDto({
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

  factory ProductConfigDto.fromListJson(Map<String, dynamic> json) {
    final ativo = _parseApiBool(json['pro_ativo']);
    final status = _parseApiBool(json['pro_status']);

    return ProductConfigDto(
      id: json['pro_produtosId'] as int,
      codigo: json['pro_codigo'] as String? ?? '',
      solucao: json['pro_solucao'] as String? ?? '',
      indicacao: json['pro_indicacao'] as String? ?? '',
      tipo: json['pro_tipo'] as String? ?? '',
      valor: _parseDouble(json['pro_valor']),
      tipoProduto: json['pro_tipo_produto'] as String? ?? '',
      isbn: json['pro_isbn'] as String?,
      percent: _parseDoubleNullable(json['pro_percent']),
      ativo: ativo,
      status: status,
      ordem: json['pro_ordem'] as int? ?? 0,
      subcategoriaId: json['pro_subcategoria_id'] as int? ?? 0,
      subcategoriaNome: (json['subcategoria']
          as Map<String, dynamic>?)?['sub_name'] as String?,
    );
  }

  factory ProductConfigDto.fromDetailJson(Map<String, dynamic> json) {
    final indicadoresJson = json['indicadores'] as Map<String, dynamic>? ?? {};
    final indicadores = <String, bool>{};
    indicadoresJson.forEach((key, value) {
      indicadores[key] = _parseApiBool(value);
    });

    final relatedList = json['relatedProducts'] as List<dynamic>? ?? [];
    final relacionados = relatedList
        .map((e) => RelatedProductDto.fromJson(e as Map<String, dynamic>))
        .toList();

    final categoriaJson = json['categoria'] as Map<String, dynamic>?;
    final subcategoriaJson = json['subcategoria'] as Map<String, dynamic>?;

    final ativo = _parseApiBool(json['ativo']);
    final status = _parseApiBool(json['status']);

    return ProductConfigDto(
      id: json['id'] as int,
      codigo: json['codigo'] as String? ?? '',
      solucao: json['nome'] as String? ?? '',
      indicacao: json['indicacao'] as String? ?? '',
      tipo: json['tipo'] as String? ?? '',
      valor: _parseDouble(json['valor']),
      tipoProduto: json['tipo_produto'] as String? ?? '',
      isbn: json['isbn'] as String?,
      percent: _parseDoubleNullable(json['percent']),
      ativo: ativo,
      status: status,
      ordem: json['ordem'] as int? ?? 0,
      subcategoriaId: subcategoriaJson?['id'] as int? ?? 0,
      categoriaNome: categoriaJson?['nome'] as String?,
      subcategoriaNome: subcategoriaJson?['nome'] as String?,
      indicadores: indicadores,
      produtosRelacionados: relacionados,
    );
  }

  ProductConfigEntity toEntity() {
    return ProductConfigEntity(
      id: id,
      codigo: codigo,
      solucao: solucao,
      indicacao: indicacao,
      tipo: tipo,
      valor: valor,
      tipoProduto: tipoProduto,
      isbn: isbn,
      percent: percent,
      ativo: ativo,
      status: status,
      ordem: ordem,
      subcategoriaId: subcategoriaId,
      categoriaNome: categoriaNome,
      subcategoriaNome: subcategoriaNome,
      indicadores: indicadores,
      produtosRelacionados:
          produtosRelacionados.map((e) => e.toEntity()).toList(),
    );
  }

  static Map<String, dynamic> toUpdateJson(ProductConfigEntity entity) {
    final json = <String, dynamic>{
      'pro_ativo': entity.ativo,
      'pro_status': entity.status,
      'pro_codigo': entity.codigo,
      'pro_solucao': entity.solucao,
      'pro_tipo': entity.tipo,
      'pro_valor': entity.valor,
      'pro_indicacao': entity.indicacao,
      'pro_tipo_produto': entity.tipoProduto,
    };

    if (entity.isLivro) {
      json['pro_isbn'] = entity.isbn;
      json['indicadores'] = entity.indicadores.entries
          .map((e) => {'id': e.key, 'valor': e.value})
          .toList();
    } else if (entity.isTecnologia) {
      json['indicadores'] = entity.indicadores.entries
          .map((e) => {'id': e.key, 'valor': e.value})
          .toList();
    } else if (entity.isServico) {
      json['pro_percent'] = entity.percent;
      json['pro_relacao'] =
          entity.produtosRelacionados.map((e) => e.id).toList();
    }

    return json;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static bool _parseApiBool(dynamic value) {
    return value == 1 || value == true;
  }

  static double? _parseDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
