import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/product_management/data/models/category_dto.dart';
import 'package:multimidiaapp/app/modules/features/product_management/data/models/product_config_dto.dart';
import 'package:multimidiaapp/app/modules/features/product_management/data/models/subcategory_dto.dart';

void main() {
  group('Preservação de horas fixas ao editar serviços', () {
    for (final field in ['horas_fixas', 'pro_horas_fixas']) {
      for (final value in <Object>['12.50', 12.5, 0]) {
        test('preserva $field=$value do detalhe até o PUT', () {
          final product = ProductConfigDto.fromDetailJson({
            'id': 1,
            'nome': 'Serviço original',
            'tipo_produto': 'servico',
            field: value,
          }).toEntity();

          final edited = product.copyWith(solucao: 'Serviço renomeado');
          final payload = ProductConfigDto.toUpdateJson(edited);

          expect(payload['pro_horas_fixas'], value == 0 ? 0.0 : 12.5);
          expect(payload['pro_solucao'], 'Serviço renomeado');
        });
      }
    }

    test('preserva horas na resposta crua de atualização e próxima edição', () {
      final product = ProductConfigDto.fromListJson({
        'pro_produtosId': 1,
        'pro_tipo_produto': 'servico',
        'pro_horas_fixas': '7.25',
      }).toEntity();

      final payload = ProductConfigDto.toUpdateJson(
        product.copyWith(valor: 150),
      );

      expect(payload['pro_horas_fixas'], 7.25);
    });

    test('mantém null para campo que não se aplica ao tipo', () {
      final product = ProductConfigDto.fromListJson({
        'pro_produtosId': 1,
        'pro_tipo_produto': 'livro',
        'pro_horas_fixas': '7.25',
      }).toEntity();

      expect(ProductConfigDto.toUpdateJson(product)['pro_horas_fixas'], isNull);
    });
  });

  group('Ordens fracionárias do catálogo', () {
    test('categoria e subcategoria preservam a última casa decimal', () {
      final category = CategoryDto.fromJson({
        'cat_categoriaId': 1,
        'cat_ordem': '9999999999.99999998',
      }).toEntity();
      final subcategory = SubcategoryDto.fromJson({
        'sub_subcategoriasId': 2,
        'sub_order': '9999999999.99999999',
      }).toEntity();

      expect(category.ordem.toJson(), '9999999999.99999998');
      expect(subcategory.ordem.toJson(), '9999999999.99999999');
      expect(category.ordem.compareTo(subcategory.ordem), lessThan(0));
    });

    test('lista, detalhe e cópia do produto preservam a ordem exata', () {
      final list = ProductConfigDto.fromListJson({
        'pro_produtosId': 1,
        'pro_ordem': '9999999999.99999998',
      }).toEntity();
      final detail = ProductConfigDto.fromDetailJson({
        'id': 1,
        'ordem': '9999999999.99999998',
      }).toEntity();
      final edited = detail.copyWith(solucao: 'Nome novo');

      expect(list.ordem, detail.ordem);
      expect(edited.ordem.toJson(), '9999999999.99999998');
      expect(ProductConfigDto.toUpdateJson(edited).containsKey('pro_ordem'),
          isFalse);
    });
  });

  test('modal preserva vínculos em vez de substituir pela lista carregada', () {
    for (final related in [
      <Map<String, dynamic>>[],
      [
        {'id': 8, 'codigo': 'P8', 'nome': 'Produto relacionado'}
      ],
    ]) {
      final product = ProductConfigDto.fromDetailJson({
        'id': 1,
        'tipo_produto': 'servico',
        'horas_fixas': 12.5,
        'relatedProducts': related,
      }).toEntity();
      final payload = ProductConfigDto.toUpdateJson(
        product.copyWith(solucao: 'Nome atualizado'),
      );
      expect(payload.containsKey('pro_relacao'), isTrue);
      expect(payload['pro_relacao'], isNull);
      expect(payload['pro_horas_fixas'], 12.5);
    }
  });
}
