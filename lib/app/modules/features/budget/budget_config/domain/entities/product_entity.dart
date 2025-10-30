import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import 'indicador_etapa_entity.dart';

/// Entidade que representa um produto no orçamento
class ProductEntity extends Equatable {
  /// ID único do produto
  final int id;

  /// Código do produto (ex: "Orto-1-A")
  final String codigo;

  /// Nome/descrição da solução
  final String solucao;

  /// Tipo de assinatura (ex: "anual")
  final String tipo;

  /// ⚠️ Se false, produto NÃO deve aparecer na listagem
  final bool ativo;

  /// Valor unitário do produto
  final double valor;

  /// Indicação de uso (ex: "1º ano - EF")
  final String indicacao;

  /// Tipo do produto (ex: "colecao", "solucao tecnologica")
  final String tipoProduto;

  /// Ordem de exibição
  final int ordem;

  /// ID da subcategoria a qual o produto pertence
  final int subcategoriaId;

  /// ✅ Estado do checkbox (true = marcado, false = desmarcado)
  final bool selecionado;

  /// Quantidade selecionada
  final int quantidade;

  /// Se teve override de valores
  final bool temOverride;

  /// Observações adicionais
  final String? observacoes;

  /// Valor original do produto
  final double valorOriginal;

  /// Status ativo original
  final bool ativoOriginal;

  /// Indicadores de etapa (ex: Pré-escola, Ensino Fundamental, etc.)
  final List<IndicadorEtapaEntity> indicadoresEtapa;

  const ProductEntity({
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

  // ========== Regras de Negócio ==========

  /// ⚠️ Produto só pode ser exibido se estiver ativo
  bool get canBeDisplayed => ativo;

  /// ✅ Checkbox está marcado
  bool get isSelected => selecionado;

  /// Valor total considerando quantidade
  double get totalValue => valor * quantidade;

  /// Verifica se teve alteração de valor
  bool get hasValueOverride => valor != valorOriginal;

  /// Verifica se teve alteração de status ativo
  bool get hasActiveOverride => ativo != ativoOriginal;

  /// Verifica se tem override de qualquer tipo
  bool get hasAnyOverride =>
      hasValueOverride || hasActiveOverride || temOverride;

  /// Formata o valor para exibição (padrão brasileiro)
  String get formattedValue {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(valor);
  }

  /// Formata o valor total para exibição (padrão brasileiro)
  String get formattedTotalValue {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(totalValue);
  }

  @override
  List<Object?> get props => [
        id,
        codigo,
        solucao,
        tipo,
        ativo,
        valor,
        indicacao,
        tipoProduto,
        ordem,
        subcategoriaId,
        selecionado,
        quantidade,
        temOverride,
        observacoes,
        valorOriginal,
        ativoOriginal,
        indicadoresEtapa,
      ];

  /// Cria uma cópia com campos alterados
  ProductEntity copyWith({
    int? id,
    String? codigo,
    String? solucao,
    String? tipo,
    bool? ativo,
    double? valor,
    String? indicacao,
    String? tipoProduto,
    int? ordem,
    int? subcategoriaId,
    bool? selecionado,
    int? quantidade,
    bool? temOverride,
    String? observacoes,
    double? valorOriginal,
    bool? ativoOriginal,
    List<IndicadorEtapaEntity>? indicadoresEtapa,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      solucao: solucao ?? this.solucao,
      tipo: tipo ?? this.tipo,
      ativo: ativo ?? this.ativo,
      valor: valor ?? this.valor,
      indicacao: indicacao ?? this.indicacao,
      tipoProduto: tipoProduto ?? this.tipoProduto,
      ordem: ordem ?? this.ordem,
      subcategoriaId: subcategoriaId ?? this.subcategoriaId,
      selecionado: selecionado ?? this.selecionado,
      quantidade: quantidade ?? this.quantidade,
      temOverride: temOverride ?? this.temOverride,
      observacoes: observacoes ?? this.observacoes,
      valorOriginal: valorOriginal ?? this.valorOriginal,
      ativoOriginal: ativoOriginal ?? this.ativoOriginal,
      indicadoresEtapa: indicadoresEtapa ?? this.indicadoresEtapa,
    );
  }

  @override
  String toString() {
    return 'ProductEntity(id: $id, codigo: $codigo, selecionado: $selecionado, ativo: $ativo, quantidade: $quantidade, valor: $valor)';
  }
}
