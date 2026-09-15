import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/data/models/budget_census_dto.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/data/models/budget_detail_dto.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/data/models/category_dto.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_create/data/models/budget_draft_dto.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_create/data/models/categoria_dto.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/data/models/budget_edit_dto.dart';
import 'package:multimidiaapp/app/shared/domain/value_objects/fractional_order.dart';

String _order(int index) => '1.${(index + 1).toString().padLeft(8, '0')}';

Map<String, dynamic> _product(int index, String level) => {
      'pro_produtosId': 40 - index,
      'pro_ordem': _order(index),
      'pro_ativo': true,
      'indicadores': <Map<String, dynamic>>[],
      'subcategoria': <String, dynamic>{
        'sub_subcategoriasId': level == 'product' ? 1 : 40 - index,
        'sub_order': _order(index),
        'categoria': <String, dynamic>{
          'cat_categoriaId': level == 'category' ? 40 - index : 1,
          'cat_ordem': _order(index),
        },
      },
    };

void main() {
  for (final level in ['category', 'subcategory', 'product']) {
    for (final path in ['draft', 'edit', 'detail']) {
      test('$path preserva a ordenação fracionária de $level', () {
        final products = List.generate(40, (index) => _product(index, level));
        late List<CategoryDTO> categories;
        if (path == 'draft') {
          categories = BudgetDraftDto.fromJson({
            'produtos': products,
            'mapa_indicadores': <String, dynamic>{}
          }).categories;
        } else if (path == 'edit') {
          final data = BudgetEditDto.fromJson({
            'produtos': products,
            'mapa_indicadores': <String, dynamic>{}
          }).toEntity();
          categories = (data.categoriesData as List)
              .map((item) => CategoryDTO.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          categories = BudgetDetailDto.fromJson({
            'orcamento_produtos': products.map((p) => {'produto': p}).toList(),
          }).categories;
        }

        final entities = categories.map((c) => c.toEntity()).toList();
        final ids = level == 'category'
            ? entities.map((c) => c.id)
            : level == 'subcategory'
                ? entities.single.orderedSubcategorias.map((s) => s.id)
                : entities.single.subcategorias.single.activeProdutos
                    .map((p) => p.id);
        expect(ids, List.generate(40, (index) => 40 - index));

        final encoded = jsonEncode(categories
            .map((c) => CategoryDTO.fromEntity(c.toEntity()).toJson())
            .toList());
        final restored = (jsonDecode(encoded) as List)
            .map((item) => CategoryDTO.fromJson(item as Map<String, dynamic>))
            .toList();
        final orders = level == 'category'
            ? restored.map((c) => c.ordem.toJson())
            : level == 'subcategory'
                ? restored.single.subcategorias.map((s) => s.ordem.toJson())
                : restored.single.subcategorias.single.produtos
                    .map((p) => p.ordem.toJson());
        expect(
            orders,
            List.generate(
                40, (i) => FractionalOrder.parse(_order(i)).toJson()));
      });
    }
  }

  for (final groupOrder in [false, true]) {
    for (final path in ['draft', 'edit']) {
      test('$path ordena indicadores por ${groupOrder ? 'grupo' : 'etapa'}',
          () {
        final map = <String, dynamic>{
          for (var i = 0; i < 40; i++)
            '${40 - i}': <String, dynamic>{
              'ine_indicadoresId': 40 - i,
              'ine_ordem': _order(i),
              'grupo': <String, dynamic>{
                'gru_gruposId': groupOrder ? 40 - i : 1,
                'gru_ordem': groupOrder ? _order(i) : '1',
              },
            },
        };
        final json = {
          'produtos': [_product(0, 'product')],
          'mapa_indicadores': map
        };
        final categories = path == 'draft'
            ? BudgetDraftDto.fromJson(json).categories
            : (BudgetEditDto.fromJson(json).categoriesData as List)
                .map((c) => CategoryDTO.fromJson(c as Map<String, dynamic>))
                .toList();
        expect(
            categories
                .single.subcategorias.single.produtos.single.indicadoresEtapa
                .map((i) => i.indicadorId),
            List.generate(40, (i) => 40 - i));
      });
    }
  }

  test('censo mantém 40 etapas e grupos próximos, inclusive no round-trip', () {
    for (final groupOrder in [false, true]) {
      final dto = CidadeCensoDto.fromJson({
        'indices': List.generate(
            40,
            (i) => <String, dynamic>{
                  'id': 40 - i,
                  'ind_ordem': _order(i),
                  'grupo': <String, dynamic>{
                    'id': groupOrder ? 40 - i : 1,
                    'ordem': groupOrder ? _order(i) : '1',
                  },
                }),
      });
      final entity = dto.toEntity();
      expect(entity.grupos.expand((g) => g.titulos).map((t) => t.id),
          List.generate(40, (i) => 40 - i));
      final restored = CidadeCensoDto.fromEntity(entity).toEntity();
      expect(restored, entity);
    }
  });

  test('categoria de criação preserva DECIMAL máximo no JSON e entity', () {
    final dto = CategoriaDto.fromJson({'cat_ordem': '9999999999.99999999'});
    expect(dto.toEntity().ordem.toJson(), '9999999999.99999999');
    expect(dto.toJson()['cat_ordem'], '9999999999.99999999');
  });
}
