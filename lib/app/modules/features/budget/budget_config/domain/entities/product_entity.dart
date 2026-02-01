import 'package:equatable/equatable.dart';
import 'package:multimidiaapp/app/shared/utils/currency_utils.dart';

import 'indicador_etapa_entity.dart';

/// Entidade que representa um produto no orçamento
class ProductEntity extends Equatable {
  final int id;
  final String codigo;
  final String solucao;
  final String tipo;

  /// Se false, produto NÃO deve aparecer na listagem
  final bool ativo;

  final double valor;
  final String indicacao;
  final String tipoProduto;
  final int ordem;
  final int subcategoriaId;

  /// Estado do checkbox (true = marcado)
  final bool selecionado;

  final int quantidade;
  final bool temOverride;
  final String? observacoes;
  final double valorOriginal;
  final bool ativoOriginal;
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

  bool get canBeDisplayed => ativo;

  bool get isSelected => selecionado;

  double get totalValue => valor * quantidade;

  /// Alias para compatibilidade com código legado
  double get valorTotal => totalValue;

  bool get hasValueOverride => valor != valorOriginal;

  bool get hasActiveOverride => ativo != ativoOriginal;

  bool get hasAnyOverride =>
      hasValueOverride || hasActiveOverride || temOverride;

  String get formattedValue => CurrencyUtils.formatBRL(valor);

  String get formattedTotalValue => CurrencyUtils.formatBRL(totalValue);

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
  bool get stringify => true;
}
