import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:multimidiaapp/app/shared/domain/value_objects/fractional_order.dart';
import 'package:multimidiaapp/app/shared/utils/currency_utils.dart';
import 'package:multimidiaapp/app/shared/utils/quantity_utils.dart';

import 'indicador_etapa_entity.dart';

part 'product_entity.g.dart';

/// Entidade que representa um produto no orçamento
@CopyWith()
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
  final FractionalOrder ordem;
  final int subcategoriaId;

  /// Estado do checkbox (true = marcado)
  final bool selecionado;

  final double quantidade;

  /// Se true, a quantidade foi definida manualmente e ignora os indicadores.
  final bool quantidadeManual;

  final bool temOverride;
  final String? observacoes;
  final double valorOriginal;
  final bool ativoOriginal;
  final List<IndicadorEtapaEntity> indicadoresEtapa;

  final double? percent;
  final double? horasFixas;
  final List<int> produtosRelacionadosIds;

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

  String get formattedQuantidade => QuantityUtils.format(quantidade);

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
        quantidadeManual,
        temOverride,
        observacoes,
        valorOriginal,
        ativoOriginal,
        indicadoresEtapa,
        percent,
        horasFixas,
        produtosRelacionadosIds,
      ];

  @override
  bool get stringify => true;
}
