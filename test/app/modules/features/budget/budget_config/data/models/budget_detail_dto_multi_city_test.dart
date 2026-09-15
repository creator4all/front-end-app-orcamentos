import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/data/models/budget_detail_dto.dart';

/// Fatia mínima de `GET /api/orcamentos/{id}` para um orçamento multi-cidade.
Map<String, dynamic> _multiCityPayload() => {
      'orc_orcamentoId': 3,
      'orc_nome': 'projeto',
      'orc_dias_validade': 60,
      'orc_status': 'rascunho',
      'orc_total': '21597260.00',
      'orc_usuario_id': 1,
      'orc_cidade_id': null,
      'orc_is_archived': true,
      'cidade': null,
      'multi_cidade': true,
      'cidades': [
        {
          'id': 297,
          'nome': 'Amapá',
          'censo_ano': 2025,
          'indices': [
            {
              'id': 1,
              'nome_etapa': 'bercario1ano',
              'titulo': 'Berçário 1 ano',
              'valor': 30,
              'grupo': {'id': 1, 'nome': 'Infantil'},
            },
          ],
        },
        {'id': 299, 'nome': 'Calçoene', 'indices': <dynamic>[]},
        {'id': 300, 'nome': 'Cutias', 'indices': <dynamic>[]},
      ],
      'censo_agregado': {'bercario1ano': 146.33},
      'orcamento_produtos': <dynamic>[],
    };

void main() {
  group('BudgetDetailDto.fromJson', () {
    test('preserva cidades e censo agregado do orçamento multi-cidade', () {
      final dto = BudgetDetailDto.fromJson(_multiCityPayload());

      expect(dto.cityIds, [297, 299, 300]);
      expect(dto.citiesData, hasLength(3));
      expect(dto.censoAgregado['bercario1ano'], 146.33);
      expect(dto.multiCity, isTrue);
      expect(dto.isArchived, isTrue);
      expect(dto.toEntity().isMultiCity, isTrue);
    });

    test('classifica como multi-cidade mesmo com uma só cidade vinculada', () {
      final payload = _multiCityPayload()
        ..['cidades'] = [
          {'id': 297, 'nome': 'Amapá', 'indices': <dynamic>[]},
        ];

      final entity = BudgetDetailDto.fromJson(payload).toEntity();

      expect(entity.cityIds, [297]);
      expect(entity.isMultiCity, isTrue,
          reason: 'o backend declara multi_cidade por orc_cidade_id nulo');
    });

    test('mantém o contrato legado de cidade única', () {
      final dto = BudgetDetailDto.fromJson({
        'orc_orcamentoId': 4,
        'orc_dias_validade': 30,
        'orc_status': 'rascunho',
        'orc_total': 0,
        'orc_usuario_id': 1,
        'orc_cidade_id': 299,
        'multi_cidade': false,
        'cidade': {
          'idCidades': 299,
          'nome_cidade': 'Calçoene',
          'cidades_has_indice_etapa': <dynamic>[],
        },
        'cidades': [
          {'id': 299, 'nome': 'Calçoene', 'indices': <dynamic>[]},
        ],
        'censo_agregado': {'bercario1ano': 60.0},
        'orcamento_produtos': <dynamic>[],
      });

      expect(dto.cityIds, [299]);
      expect(dto.multiCity, isFalse);
      expect(dto.toEntity().isMultiCity, isFalse);
      expect(dto.censoAgregado['bercario1ano'], 60.0);
    });

    test('deriva de `orc_cidade_id` quando o payload não traz `multi_cidade`',
        () {
      final payload = _multiCityPayload()
        ..remove('multi_cidade')
        ..['cidades'] = [
          {'id': 297, 'nome': 'Amapá', 'indices': <dynamic>[]},
        ];

      final entity = BudgetDetailDto.fromJson(payload).toEntity();

      expect(entity.multiCity, isTrue);
      expect(entity.isMultiCity, isTrue);
    });

    test('não classifica pela quantidade de cidades sem nenhuma chave', () {
      final payload = _multiCityPayload()
        ..remove('multi_cidade')
        ..remove('orc_cidade_id');

      final entity = BudgetDetailDto.fromJson(payload).toEntity();

      expect(entity.cityIds, hasLength(3));
      expect(entity.multiCity, isNull);
      expect(entity.isMultiCity, isFalse);
    });
  });
}
