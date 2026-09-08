import 'package:multimidiaapp/app/shared/domain/value_objects/fractional_order.dart';

import '../../../../../../shared/utils/api_number_parser.dart';
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
  final FractionalOrder ordem;
  final int subcategoriaId;
  final bool selecionado;
  final double quantidade;
  final bool quantidadeManual;
  final bool temOverride;
  final String? observacoes;
  final double valorOriginal;
  final bool ativoOriginal;
  final List<IndicadorEtapaEntity> indicadoresEtapa;
  final double? percent;
  final double? horasFixas;
  final List<int> produtosRelacionadosIds;

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
    this.quantidadeManual = false,
    required this.temOverride,
    this.observacoes,
    required this.valorOriginal,
    required this.ativoOriginal,
    required this.indicadoresEtapa,
    this.percent,
    this.horasFixas,
    this.produtosRelacionadosIds = const [],
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

      final double valor = ApiNumberParser.toDouble(
        orcProduto?['op_valor'] ?? json['pro_valor'] ?? json['valor'],
      );
      final String indicacao =
          (json['pro_indicacao'] ?? json['indicacao'] ?? '') as String;
      final String tipoProduto =
          (json['pro_tipo_produto'] ?? json['tipo_produto'] ?? '') as String;

      final FractionalOrder ordem =
          FractionalOrder.parse(json['pro_ordem'] ?? json['ordem']);
      final int subcategoriaId =
          ApiNumberParser.toIntOrNull(json['pro_subcategoria_id']) ??
              ApiNumberParser.toInt(json['subcategoria_id']);

      final bool selecionado = _parseBool(
        orcProduto?['op_selecionado'] ??
            orcProduto?['selecionado'] ??
            json['selecionado'] ??
            true,
      );
      final double quantidade = ApiNumberParser.toDouble(
        orcProduto?['op_quantidade'] ??
            orcProduto?['quantidade'] ??
            json['quantidade'],
      );
      final bool quantidadeManual = _parseBool(
        orcProduto?['op_quantidade_manual'] ??
            orcProduto?['quantidade_manual'] ??
            json['quantidade_manual'] ??
            false,
      );

      final bool temOverride = (json['tem_override'] as bool?) ?? false;
      final String? observacoes = json['observacoes'] as String?;

      // Valores originais com fallback para valores atuais
      final double valorOriginal =
          ApiNumberParser.toDoubleOrNull(json['valor_original']) ?? valor;
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

      final double? percent = json['pro_percent'] == null
          ? null
          : ApiNumberParser.toDouble(json['pro_percent']);
      final double? horasFixas = json['pro_horas_fixas'] == null
          ? null
          : ApiNumberParser.toDouble(json['pro_horas_fixas']);
      final List<int> produtosRelacionadosIds =
          (json['produtos_relacionados'] as List?)
                  ?.whereType<Map>()
                  .map((e) => (e['pro_produtosId'] as num?)?.toInt() ?? 0)
                  .where((id) => id > 0)
                  .toList() ??
              const [];

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
        quantidadeManual: quantidadeManual,
        temOverride: temOverride,
        observacoes: observacoes,
        valorOriginal: valorOriginal,
        ativoOriginal: ativoOriginal,
        indicadoresEtapa: indicadoresEtapa,
        percent: percent,
        horasFixas: horasFixas,
        produtosRelacionadosIds: produtosRelacionadosIds,
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
      quantidadeManual: quantidadeManual,
      temOverride: temOverride,
      observacoes: observacoes,
      valorOriginal: valorOriginal,
      ativoOriginal: ativoOriginal,
      indicadoresEtapa: indicadoresEtapa,
      percent: percent,
      horasFixas: horasFixas,
      produtosRelacionadosIds: produtosRelacionadosIds,
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
      'ordem': ordem.toJson(),
      'subcategoria_id': subcategoriaId,
      'selecionado': selecionado,
      'quantidade': quantidade,
      'quantidade_manual': quantidadeManual,
      'tem_override': temOverride,
      'observacoes': observacoes,
      'valor_original': valorOriginal,
      'ativo_original': ativoOriginal,
      'indicadores_etapa': indicadoresEtapa
          .map((e) => IndicadorEtapaDTO.fromEntity(e).toJson())
          .toList(),
      if (percent != null) 'pro_percent': percent,
      if (horasFixas != null) 'pro_horas_fixas': horasFixas,
      'produtos_relacionados':
          produtosRelacionadosIds.map((id) => {'pro_produtosId': id}).toList(),
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
      quantidadeManual: entity.quantidadeManual,
      temOverride: entity.temOverride,
      observacoes: entity.observacoes,
      valorOriginal: entity.valorOriginal,
      ativoOriginal: entity.ativoOriginal,
      indicadoresEtapa: entity.indicadoresEtapa,
      percent: entity.percent,
      horasFixas: entity.horasFixas,
      produtosRelacionadosIds: entity.produtosRelacionadosIds,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }
}
