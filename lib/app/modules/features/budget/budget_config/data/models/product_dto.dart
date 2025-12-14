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
      // Parse cada campo com fallbacks para formato simplificado e formato do banco (prefixo pro_)
      final int id = json['id'] ?? json['pro_produtosId'] as int;
      final String codigo = (json['codigo'] ?? '') as String;
      final String solucao =
          (json['solucao'] ?? json['pro_solucao'] ?? '') as String;
      final String tipo = (json['tipo'] ?? '') as String;

      // 'ativo' pode vir como 'ativo', 'status' ou 'pro_status'
      final dynamic rawAtivo =
          json['ativo'] ?? json['status'] ?? json['pro_status'];
      final bool ativo = rawAtivo is bool ? rawAtivo : (rawAtivo == 1);

      final double valor = (json['valor'] ?? json['pro_valor'] ?? 0).toDouble();
      final String indicacao =
          (json['indicacao'] ?? json['pro_indicacao'] ?? '') as String;
      final String tipoProduto = (json['tipo_produto'] ?? '') as String;

      // Parse defensivo: ordem pode vir null, vazio ou 0
      final int ordem = (json['ordem'] as int?) ?? 0;
      final int subcategoriaId =
          (json['subcategoria_id'] ?? json['pro_subcategoria_id'] as int?) ?? 0;

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
      // Depois tenta formato simplificado 'indicadores' (retorno da criação ou carregamento completo)
      else if (json['indicadores'] != null && json['indicadores'] is List) {
        indicadoresEtapa = (json['indicadores'] as List<dynamic>).map((item) {
          final ind = item as Map<String, dynamic>;

          // Tentar extrair o objeto aninhado indicador_etapa (pode vir como 'indicador_etapa' ou 'indicadorEtapa')
          final indEtapa = (ind['indicador_etapa'] ?? ind['indicadorEtapa'])
              as Map<String, dynamic>?;

          // Tentar extrair o objeto aninhado grupo (dentro de indicador_etapa)
          final grupo = (indEtapa?['grupo']) as Map<String, dynamic>?;

          // Extração de IDs e Valores com fallback para nomes de colunas do banco (que aparecem no select)
          final prodIndId = ind['id'] ?? ind['prd_produtos_indicadoresId'] ?? 0;
          final valor = ind['valor'] ?? ind['prd_valor'] ?? false;

          final indId = indEtapa?['id'] ?? indEtapa?['ine_indicadoresId'] ?? 0;
          final indNome = indEtapa?['nome'] ?? indEtapa?['ine_nome'] ?? '';

          // Tenta extrair ID do grupo do objeto grupo ou diretamente do indicadorEtapa (FK)
          final grpId = grupo?['id'] ??
              grupo?['gru_gruposId'] ??
              indEtapa?['gru_gruposId'] ??
              0;
          final grpNome = grupo?['nome'] ??
              grupo?['gru_grupo_nome'] ??
              grupo?['nome_grupo'] ??
              '';

          // Conversão segura de booleano (pode vir 0/1 do banco)
          bool selecionado = false;
          if (valor is bool) {
            selecionado = valor;
          } else if (valor is int) {
            selecionado = valor == 1;
          }

          return IndicadorEtapaEntity(
            produtoIndicadorId: prodIndId is int
                ? prodIndId
                : int.tryParse(prodIndId.toString()) ?? 0,
            indicadorId:
                indId is int ? indId : int.tryParse(indId.toString()) ?? 0,
            indicadorNome: indNome.toString(),
            nomeEtapa: indNome.toString(),
            grupoId: grpId is int ? grpId : int.tryParse(grpId.toString()) ?? 0,
            grupoNome: grpNome.toString(),
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
