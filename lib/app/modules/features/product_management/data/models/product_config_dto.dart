import '../../../../../shared/domain/value_objects/fractional_order.dart';
import '../../../../../shared/utils/api_number_parser.dart';
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
  final double? horasFixas;
  final bool ativo;
  final bool status;
  final FractionalOrder ordem;
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
    this.horasFixas,
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
      valor: ApiNumberParser.toDouble(json['pro_valor']),
      tipoProduto: json['pro_tipo_produto'] as String? ?? '',
      isbn: json['pro_isbn'] as String?,
      percent: ApiNumberParser.toDoubleOrNull(json['pro_percent']),
      horasFixas: ApiNumberParser.toDoubleOrNull(json['pro_horas_fixas']),
      ativo: ativo,
      status: status,
      ordem: FractionalOrder.parse(json['pro_ordem']),
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
      valor: ApiNumberParser.toDouble(json['valor']),
      tipoProduto: json['tipo_produto'] as String? ?? '',
      isbn: json['isbn'] as String?,
      percent: ApiNumberParser.toDoubleOrNull(json['percent']),
      horasFixas: ApiNumberParser.toDoubleOrNull(
        json['horas_fixas'] ?? json['pro_horas_fixas'],
      ),
      ativo: ativo,
      status: status,
      ordem: FractionalOrder.parse(json['ordem']),
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
      horasFixas: horasFixas,
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

  /// Monta o corpo de `PUT /api/produtos/{id}`.
  ///
  /// O endpoint valida atualização completa: todas as chaves do schema
  /// precisam estar presentes, mesmo quando o valor é nulo. Campos que não se
  /// aplicam ao tipo do produto são enviados como `null` — o backend já os
  /// ignora ou normaliza conforme `pro_tipo_produto`.
  static Map<String, dynamic> toUpdateJson(ProductConfigEntity entity) {
    final indicadores = entity.indicadores.entries
        .map((e) => {'id': e.key, 'valor': e.value})
        .toList();

    return <String, dynamic>{
      'pro_ativo': entity.ativo,
      'pro_status': entity.status,
      'pro_codigo': entity.codigo,
      'pro_solucao': entity.solucao,
      'pro_tipo': entity.tipo,
      'pro_valor': entity.valor,
      'pro_indicacao': entity.indicacao,
      'pro_tipo_produto': entity.tipoProduto,
      'pro_subcategoria_id': entity.subcategoriaId,
      'pro_isbn': entity.isLivro ? entity.isbn : null,
      'indicadores': entity.isServico ? const [] : indicadores,
      // O modal não edita vínculos; null preserva as relações existentes.
      'pro_relacao': null,
      'pro_percent': entity.isServico ? entity.percent : null,
      // A edição não expõe horas fixas; reenviar o valor evita zerá-lo na API.
      'pro_horas_fixas': entity.isServico ? entity.horasFixas : null,
    };
  }

  static bool _parseApiBool(dynamic value) {
    return value == 1 || value == true;
  }
}
