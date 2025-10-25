import '../../domain/entities/product_entity.dart';

/// DTO para parsing JSON dos produtos da API
class ProductDTO {
  final int id;
  final String codigo;
  final String solucao;
  final String tipo;
  final bool ativo;
  final double valor;
  final String indicacao;
  final String tipoProduto;
  final int ordem;
  final int subcategoriaId;
  final bool selecionado;
  final int quantidade;
  final bool temOverride;
  final String? observacoes;
  final double valorOriginal;
  final bool ativoOriginal;
  final List<dynamic> indicadoresEtapa;

  ProductDTO({
    required this.id,
    required this.codigo,
    required this.solucao,
    required this.tipo,
    required this.ativo,
    required this.valor,
    required this.indicacao,
    required this.tipoProduto,
    required this.ordem,
    required this.subcategoriaId,
    required this.selecionado,
    required this.quantidade,
    required this.temOverride,
    this.observacoes,
    required this.valorOriginal,
    required this.ativoOriginal,
    required this.indicadoresEtapa,
  });

  /// Cria um DTO a partir do JSON da API
  factory ProductDTO.fromJson(Map<String, dynamic> json) {
    try {
      print(
          '         🔍 [ProductDTO] Parseando produto ID: ${json['id']}, Código: ${json['codigo']}');

      // Parse cada campo individualmente com tratamento de erro
      final int id = json['id'] as int;
      print('            ✅ id: $id');

      final String codigo = json['codigo'] as String;
      print('            ✅ codigo: $codigo');

      final String solucao = json['solucao'] as String;
      print('            ✅ solucao: $solucao (${solucao.length} chars)');

      // tipo: campo obrigatório da API
      final String tipo = json['tipo'] as String;
      print('            ✅ tipo: $tipo');

      final bool ativo = json['ativo'] as bool;
      print('            ✅ ativo: $ativo');

      final double valor = (json['valor'] as num).toDouble();
      print('            ✅ valor: $valor');

      // indicacao: campo obrigatório da API
      final String indicacao = json['indicacao'] as String;
      print('            ✅ indicacao: $indicacao');

      final String tipoProduto = json['tipo_produto'] as String;
      print('            ✅ tipo_produto: $tipoProduto');

      final int ordem = json['ordem'] as int;
      print('            ✅ ordem: $ordem');

      final int subcategoriaId = json['subcategoria_id'] as int;
      print('            ✅ subcategoria_id: $subcategoriaId');

      final bool selecionado = json['selecionado'] as bool;
      print('            ✅ selecionado: $selecionado');

      final int quantidade = (json['quantidade'] as num).toInt();
      print('            ✅ quantidade: $quantidade');

      // tem_override: campo obrigatório da API
      final bool temOverride = json['tem_override'] as bool;
      print('            ✅ tem_override: $temOverride');

      final String? observacoes = json['observacoes'] as String?;
      print('            ✅ observacoes: $observacoes');

      // valor_original e ativo_original: campos obrigatórios da API
      final double valorOriginal = (json['valor_original'] as num).toDouble();
      print('            ✅ valor_original: $valorOriginal');

      final bool ativoOriginal = json['ativo_original'] as bool;
      print('            ✅ ativo_original: $ativoOriginal');

      // indicadores_etapa: campo obrigatório da API (pode ser array vazio)
      final List<dynamic> indicadoresEtapa =
          json['indicadores_etapa'] as List<dynamic>;
      print(
          '            ✅ indicadores_etapa: ${indicadoresEtapa.length} itens');

      return ProductDTO(
        id: id,
        codigo: codigo,
        solucao: solucao,
        tipo: tipo,
        ativo: ativo,
        valor: valor,
        indicacao: indicacao,
        tipoProduto: tipoProduto,
        ordem: ordem,
        subcategoriaId: subcategoriaId,
        selecionado: selecionado,
        quantidade: quantidade,
        temOverride: temOverride,
        observacoes: observacoes,
        valorOriginal: valorOriginal,
        ativoOriginal: ativoOriginal,
        indicadoresEtapa: indicadoresEtapa,
      );
    } catch (e, stackTrace) {
      print('❌ [ProductDTO] Erro ao parsear produto: $e');
      print('📄 JSON recebido: $json');
      print('📋 Tipo do erro: ${e.runtimeType}');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Converte o DTO para Entity
  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      codigo: codigo,
      solucao: solucao,
      tipo: tipo,
      ativo: ativo,
      valor: valor,
      indicacao: indicacao,
      tipoProduto: tipoProduto,
      ordem: ordem,
      subcategoriaId: subcategoriaId,
      selecionado: selecionado,
      quantidade: quantidade,
      temOverride: temOverride,
      observacoes: observacoes,
      valorOriginal: valorOriginal,
      ativoOriginal: ativoOriginal,
      indicadoresEtapa: indicadoresEtapa,
    );
  }

  /// Converte o DTO para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'solucao': solucao,
      'tipo': tipo,
      'ativo': ativo,
      'valor': valor,
      'indicacao': indicacao,
      'tipo_produto': tipoProduto,
      'ordem': ordem,
      'subcategoria_id': subcategoriaId,
      'selecionado': selecionado,
      'quantidade': quantidade,
      'tem_override': temOverride,
      'observacoes': observacoes,
      'valor_original': valorOriginal,
      'ativo_original': ativoOriginal,
      'indicadores_etapa': indicadoresEtapa,
    };
  }

  /// Converte uma Entity para DTO
  factory ProductDTO.fromEntity(ProductEntity entity) {
    return ProductDTO(
      id: entity.id,
      codigo: entity.codigo,
      solucao: entity.solucao,
      tipo: entity.tipo,
      ativo: entity.ativo,
      valor: entity.valor,
      indicacao: entity.indicacao,
      tipoProduto: entity.tipoProduto,
      ordem: entity.ordem,
      subcategoriaId: entity.subcategoriaId,
      selecionado: entity.selecionado,
      quantidade: entity.quantidade,
      temOverride: entity.temOverride,
      observacoes: entity.observacoes,
      valorOriginal: entity.valorOriginal,
      ativoOriginal: entity.ativoOriginal,
      indicadoresEtapa: entity.indicadoresEtapa,
    );
  }
}
