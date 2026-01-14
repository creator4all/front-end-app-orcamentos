import '../../domain/entities/product_config_entity.dart';

/// DTO para produto relacionado
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
      codigo: json['code'] as String? ?? json['codigo'] as String? ?? '',
      nome: json['name'] as String? ?? json['nome'] as String? ?? '',
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

/// DTO para parsing JSON de produto completo (para edição)
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

  /// Factory para resposta da lista de produtos (formato diferente)
  factory ProductConfigDto.fromListJson(Map<String, dynamic> json) {
    // API retorna ativo/status como int (1 = true, 0 = false)
    final ativoValue = json['pro_ativo'];
    final ativo = ativoValue == 1 || ativoValue == true;
    final statusValue = json['pro_status'];
    final status = statusValue == 1 || statusValue == true;

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

  /// Factory para resposta de detalhe do produto
  factory ProductConfigDto.fromDetailJson(Map<String, dynamic> json) {
    // Parse indicadores
    final indicadoresJson = json['indicadores'] as Map<String, dynamic>? ?? {};
    final indicadores = <String, bool>{};
    indicadoresJson.forEach((key, value) {
      indicadores[key] = value == true || value == 1;
    });

    // Parse produtos relacionados
    final relatedList = json['relatedProducts'] as List<dynamic>? ?? [];
    final relacionados = relatedList
        .map((e) => RelatedProductDto.fromJson(e as Map<String, dynamic>))
        .toList();

    // Parse categoria e subcategoria
    final categoriaJson = json['categoria'] as Map<String, dynamic>?;
    final subcategoriaJson = json['subcategoria'] as Map<String, dynamic>?;

    // API retorna ativo/status como int (1 = true, 0 = false)
    final ativoValue = json['ativo'];
    final ativo = ativoValue == 1 || ativoValue == true;
    final statusValue = json['status'];
    final status = statusValue == 1 || statusValue == true;

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

  /// Converte entidade para JSON do PUT
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

    // Campos condicionais por tipo
    if (entity.isLivro) {
      json['pro_isbn'] = entity.isbn;
      // Indicadores para livro e tecnologia
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

  static double? _parseDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
