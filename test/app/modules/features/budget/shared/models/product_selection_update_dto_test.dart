import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/indicador_etapa_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/product_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/shared/models/product_selection_update_dto.dart';
import 'package:multimidiaapp/app/shared/domain/value_objects/fractional_order.dart';

ProductEntity _produto({
  String? observacoes,
  bool indicadoresSelecionados = true,
}) {
  return ProductEntity(
    id: 10,
    codigo: 'P10',
    solucao: 'Produto',
    tipo: 'tecnologia',
    ativo: true,
    valor: 12,
    indicacao: '',
    tipoProduto: 'tecnologia',
    ordem: FractionalOrder.zero,
    subcategoriaId: 1,
    selecionado: true,
    quantidade: 2,
    quantidadeManual: false,
    temOverride: false,
    observacoes: observacoes,
    valorOriginal: 10,
    ativoOriginal: true,
    indicadoresEtapa: [
      IndicadorEtapaEntity(
        produtoIndicadorId: 1,
        indicadorId: 1,
        indicadorNome: 'ef1ano',
        nomeEtapa: 'ef1ano',
        grupoId: 1,
        grupoNome: 'Etapas',
        selecionado: indicadoresSelecionados,
      ),
    ],
  );
}

void main() {
  group('ProductSelectionUpdateDto', () {
    test('serializa observações e valor alterado', () {
      final json = ProductSelectionUpdateDto.fromEntity(
        _produto(observacoes: 'nota do cliente'),
      ).toJson();

      expect(json['observacoes'], 'nota do cliente');
      expect(json['valor'], 12);
    });

    test('envia o preço mesmo quando é igual ao catálogo atual', () {
      final produto = _produto().copyWith(valor: 10);

      expect(produto.valorOriginal, 10);
      expect(
          ProductSelectionUpdateDto.fromEntity(produto).toJson()['valor'], 10);
      expect(
        ProductSelectionUpdateDto.fromEntity(produto)
            .toJsonForMultiCity()['valor'],
        10,
      );
    });

    test('envia indicadores_etapa vazio quando todos foram desmarcados', () {
      final json = ProductSelectionUpdateDto.fromEntity(
        _produto(indicadoresSelecionados: false),
      ).toJson();

      expect(json['indicadores_etapa'], [
        {'produto_indicador_id': 1, 'selecionado': false},
      ]);
    });

    test('multi-cidade também envia observações', () {
      final json = ProductSelectionUpdateDto.fromEntity(
        _produto(observacoes: 'obs'),
      ).toJsonForMultiCity();

      expect(json['observacoes'], 'obs');
    });
  });
}
