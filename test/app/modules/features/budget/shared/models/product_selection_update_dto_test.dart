import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/indicador_etapa_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/product_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/shared/models/product_selection_update_dto.dart';

ProductEntity _createProduct({
  List<IndicadorEtapaEntity> indicadores = const [],
}) {
  return ProductEntity(
    id: 1,
    codigo: 'P001',
    solucao: 'Produto Teste',
    tipo: 'tipo',
    ativo: true,
    valor: 100.0,
    indicacao: '',
    tipoProduto: 'produto',
    ordem: 0,
    subcategoriaId: 1,
    selecionado: true,
    quantidade: 10,
    quantidadeManual: false,
    temOverride: false,
    valorOriginal: 100.0,
    ativoOriginal: true,
    indicadoresEtapa: indicadores,
  );
}

IndicadorEtapaEntity _createIndicador({
  required int produtoIndicadorId,
  bool selecionado = false,
}) {
  return IndicadorEtapaEntity(
    produtoIndicadorId: produtoIndicadorId,
    indicadorId: 1,
    indicadorNome: 'Indicador',
    nomeEtapa: 'etapa',
    grupoId: 1,
    grupoNome: 'Grupo',
    selecionado: selecionado,
  );
}

void main() {
  group('ProductSelectionUpdateDto.fromEntity', () {
    test('filtra indicadores com produtoIndicadorId <= 0', () {
      final product = _createProduct(
        indicadores: [
          _createIndicador(produtoIndicadorId: 0, selecionado: true),
          _createIndicador(produtoIndicadorId: 5, selecionado: true),
          _createIndicador(produtoIndicadorId: 0, selecionado: false),
          _createIndicador(produtoIndicadorId: 10, selecionado: false),
        ],
      );

      final dto = ProductSelectionUpdateDto.fromEntity(product);

      expect(dto.indicadores, isNotNull);
      expect(dto.indicadores!.length, 2);
      expect(
        dto.indicadores!.every((i) => i.produtoIndicadorId > 0),
        isTrue,
      );
    });

    test('retorna indicadores null quando todos tem id 0', () {
      final product = _createProduct(
        indicadores: [
          _createIndicador(produtoIndicadorId: 0, selecionado: true),
          _createIndicador(produtoIndicadorId: 0, selecionado: false),
        ],
      );

      final dto = ProductSelectionUpdateDto.fromEntity(product);

      expect(dto.indicadores, isNull);
    });

    test('toJson não emite indicadores_etapa quando lista é null', () {
      final product = _createProduct(
        indicadores: [
          _createIndicador(produtoIndicadorId: 0),
        ],
      );

      final dto = ProductSelectionUpdateDto.fromEntity(product);
      final json = dto.toJson();

      expect(json.containsKey('indicadores_etapa'), isFalse);
    });

    test('toJson emite indicadores_etapa quando há indicadores válidos', () {
      final product = _createProduct(
        indicadores: [
          _createIndicador(produtoIndicadorId: 5, selecionado: true),
        ],
      );

      final dto = ProductSelectionUpdateDto.fromEntity(product);
      final json = dto.toJson();

      expect(json.containsKey('indicadores_etapa'), isTrue);
      expect((json['indicadores_etapa'] as List).length, 1);
    });
  });

  group('ProductSelectionUpdateDto.delta', () {
    test(
        'filtra indicadores com id 0 mesmo quando estão em changedIndicatorIds',
        () {
      final product = _createProduct(
        indicadores: [
          _createIndicador(produtoIndicadorId: 0, selecionado: true),
          _createIndicador(produtoIndicadorId: 3, selecionado: true),
        ],
      );

      final dto = ProductSelectionUpdateDto.delta(
        entity: product,
        selecionadoChanged: false,
        quantidadeChanged: false,
        valorChanged: false,
        changedIndicatorIds: const {0, 3},
      );

      expect(dto.indicadores, isNotNull);
      expect(dto.indicadores!.length, 1);
      expect(dto.indicadores!.first.produtoIndicadorId, 3);
    });

    test('retorna indicadores null quando apenas id 0 mudou', () {
      final product = _createProduct(
        indicadores: [
          _createIndicador(produtoIndicadorId: 0, selecionado: true),
        ],
      );

      final dto = ProductSelectionUpdateDto.delta(
        entity: product,
        selecionadoChanged: false,
        quantidadeChanged: false,
        valorChanged: false,
        changedIndicatorIds: const {0},
      );

      expect(dto.indicadores, isNull);
    });

    test(
        'toJsonDelta não emite indicadores_etapa quando filtragem remove todos',
        () {
      final product = _createProduct(
        indicadores: [
          _createIndicador(produtoIndicadorId: 0, selecionado: true),
        ],
      );

      final dto = ProductSelectionUpdateDto.delta(
        entity: product,
        selecionadoChanged: false,
        quantidadeChanged: false,
        valorChanged: false,
        changedIndicatorIds: const {0},
      );

      final json = dto.toJsonDelta();

      expect(json.containsKey('indicadores_etapa'), isFalse);
    });
  });
}
