import '../../domain/entities/indicador_etapa_entity.dart';
import '../../domain/entities/product_entity.dart';
import 'indicador_etapa_dto.dart';

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

  /// Cria um DTO a partir do JSON da API
  /// Suporta tanto formato completo quanto simplificado (criação de orçamento)
  factory ProductDTO.fromJson(Map<String, dynamic> json) {
    try {
      // Parse cada campo com fallbacks para formato simplificado
      final int id = json['id'] as int;
      final String codigo = (json['codigo'] as String?) ?? '';
      final String solucao = json['solucao'] as String;
      final String tipo = (json['tipo'] as String?) ?? '';

      // 'ativo' pode vir como 'ativo' ou 'status' dependendo do endpoint
      final bool ativo = (json['ativo'] ?? json['status']) as bool? ?? true;
      final double valor = (json['valor'] as num).toDouble();
      final String indicacao = (json['indicacao'] as String?) ?? '';
      final String tipoProduto = (json['tipo_produto'] as String?) ?? '';

      // Parse defensivo: ordem pode vir null, vazio ou 0
      final int ordem = (json['ordem'] as int?) ?? 0;
      final int subcategoriaId = (json['subcategoria_id'] as int?) ?? 0;

      // Extrair selecionado/quantidade de 'orcamento_produto' ou diretamente
      final orcProduto = json['orcamento_produto'] as Map<String, dynamic>?;
      final bool selecionado =
          (orcProduto?['selecionado'] ?? json['selecionado']) as bool? ?? true;
      final int quantidade =
          ((orcProduto?['quantidade'] ?? json['quantidade']) as num?)
                  ?.toInt() ??
              0;

      final bool temOverride = (json['tem_override'] as bool?) ?? false;
      final String? observacoes = json['observacoes'] as String?;

      // Valores originais com fallback para valores atuais
      final double valorOriginal =
          (json['valor_original'] as num?)?.toDouble() ?? valor;
      final bool ativoOriginal = (json['ativo_original'] as bool?) ?? ativo;

      // Parse indicadores - suporta 'indicadores_etapa' ou 'indicadores'
      List<IndicadorEtapaEntity> indicadoresEtapa = [];

      // Primeiro tenta formato completo 'indicadores_etapa'
      if (json['indicadores_etapa'] != null &&
          json['indicadores_etapa'] is List) {
        indicadoresEtapa = (json['indicadores_etapa'] as List<dynamic>)
            .map((item) =>
                IndicadorEtapaDTO.fromJson(item as Map<String, dynamic>)
                    .toEntity())
            .toList();
      }
      // Depois tenta formato simplificado 'indicadores' (retorno da criação)
      else if (json['indicadores'] != null && json['indicadores'] is List) {
        indicadoresEtapa = (json['indicadores'] as List<dynamic>).map((item) {
          final ind = item as Map<String, dynamic>;
          final indEtapa = ind['indicador_etapa'] as Map<String, dynamic>?;
          return IndicadorEtapaEntity(
            produtoIndicadorId: (ind['id'] as int?) ?? 0,
            indicadorId: (indEtapa?['id'] as int?) ?? 0,
            indicadorNome: (indEtapa?['nome'] as String?) ?? '',
            nomeEtapa: (indEtapa?['nome'] as String?) ?? '', // Added nomeEtapa
            grupoId: 0, // Não disponível no formato simplificado
            grupoNome: '', // Não disponível no formato simplificado
            selecionado: (ind['valor'] as bool?) ?? false,
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
      'indicadores_etapa': indicadoresEtapa
          .map((e) => IndicadorEtapaDTO.fromEntity(e).toJson())
          .toList(),
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
