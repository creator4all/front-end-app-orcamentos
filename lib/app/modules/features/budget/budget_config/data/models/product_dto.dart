import '../../domain/entities/indicador_etapa_entity.dart';
import '../../domain/entities/product_entity.dart';
import 'indicador_etapa_dto.dart';

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
  final double quantidade;
  final bool temOverride;
  final String? observacoes;
  final double valorOriginal;
  final bool ativoOriginal;
  final List<IndicadorEtapaEntity> indicadoresEtapa;

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

  factory ProductDTO.fromJson(Map<String, dynamic> json) {
    try {
      final int id = (json['pro_produtosId'] as num?)?.toInt() ??
          (json['id'] as num?)?.toInt() ??
          0;
      final String codigo =
          (json['pro_codigo'] ?? json['codigo'] ?? '') as String;
      final String solucao =
          (json['pro_solucao'] ?? json['solucao'] ?? '') as String;
      final String tipo = (json['pro_tipo'] ?? json['tipo'] ?? '') as String;

      final dynamic rawAtivo =
          json['pro_ativo'] ?? json['pro_status'] ?? json['status'];
      final bool ativo = rawAtivo is bool ? rawAtivo : (rawAtivo == 1);

      final orcProduto = json['orcamento_produto'] as Map<String, dynamic>?;

      final double valor = double.tryParse(
              (orcProduto?['op_valor'] ?? json['pro_valor'] ?? json['valor'])
                      ?.toString() ??
                  '0') ??
          0.0;
      final String indicacao =
          (json['pro_indicacao'] ?? json['indicacao'] ?? '') as String;
      final String tipoProduto =
          (json['pro_tipo_produto'] ?? json['tipo_produto'] ?? '') as String;

      final int ordem = (json['pro_ordem'] as num?)?.toInt() ??
          (json['ordem'] as num?)?.toInt() ??
          0;
      final int subcategoriaId =
          (json['pro_subcategoria_id'] as num?)?.toInt() ??
              (json['subcategoria_id'] as num?)?.toInt() ??
              0;

      final bool selecionado = _parseBool(
        orcProduto?['op_selecionado'] ??
            orcProduto?['selecionado'] ??
            json['selecionado'] ??
            true,
      );
      final double quantidade = _parseDouble(
        orcProduto?['op_quantidade'] ??
            orcProduto?['quantidade'] ??
            json['quantidade'],
      );

      final bool temOverride = (json['tem_override'] as bool?) ?? false;
      final String? observacoes = json['observacoes'] as String?;

      // Valores originais com fallback para valores atuais
      final double valorOriginal =
          (json['valor_original'] as num?)?.toDouble() ?? valor;
      final bool ativoOriginal = (json['ativo_original'] as bool?) ?? ativo;

      List<IndicadorEtapaEntity> indicadoresEtapa = [];

      if (json['indicadores_etapa'] != null &&
          json['indicadores_etapa'] is List) {
        indicadoresEtapa = (json['indicadores_etapa'] as List<dynamic>)
            .map((item) =>
                IndicadorEtapaDTO.fromJson(item as Map<String, dynamic>)
                    .toEntity())
            .toList();
      } else if (json['indicadores'] != null && json['indicadores'] is List) {
        // Fallback de contrato: em alguns endpoints os indicadores vêm em
        indicadoresEtapa = (json['indicadores'] as List<dynamic>).map((item) {
          final ind = item as Map<String, dynamic>;
          final indEtapa = ind['indicador_etapa'] as Map<String, dynamic>?;
          final grupo = indEtapa?['grupo'] as Map<String, dynamic>?;

          // Support prd_valor (bool) as selecionado indicator
          final dynamic rawSel = ind['selecionado'] ?? ind['prd_valor'];
          final bool selecionado = rawSel is bool ? rawSel : (rawSel == 1);

          return IndicadorEtapaEntity(
            produtoIndicadorId:
                (ind['prd_produtos_indicadoresId'] as num?)?.toInt() ??
                    (ind['id'] as num?)?.toInt() ??
                    0,
            indicadorId: (indEtapa?['ine_indicadoresId'] as num?)?.toInt() ??
                (indEtapa?['id'] as num?)?.toInt() ??
                0,
            indicadorNome: (indEtapa?['ine_titulo'] ??
                indEtapa?['titulo'] ??
                indEtapa?['nome'] ??
                '') as String,
            nomeEtapa:
                (indEtapa?['ine_nome'] ?? indEtapa?['nome'] ?? '') as String,
            grupoId: (grupo?['gru_gruposId'] as num?)?.toInt() ??
                (grupo?['id'] as num?)?.toInt() ??
                (indEtapa?['gru_gruposId'] as num?)?.toInt() ??
                0,
            grupoNome: (grupo?['gru_grupo_nome'] ??
                grupo?['nome'] ??
                grupo?['nome_grupo'] ??
                '') as String,
            selecionado: selecionado,
          );
        }).toList();
      }

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
    } catch (e) {
      rethrow;
    }
  }

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
      selecionado: quantidade > 0 ? selecionado : false,
      quantidade: quantidade,
      temOverride: temOverride,
      observacoes: observacoes,
      valorOriginal: valorOriginal,
      ativoOriginal: ativoOriginal,
      indicadoresEtapa: indicadoresEtapa,
    );
  }

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
      'indicadores_etapa': indicadoresEtapa
          .map((e) => IndicadorEtapaDTO.fromEntity(e).toJson())
          .toList(),
    };
  }

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

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}
