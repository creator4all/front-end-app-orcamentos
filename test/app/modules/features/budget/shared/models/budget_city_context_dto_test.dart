import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/budget/shared/models/budget_city_context_dto.dart';

void main() {
  group('BudgetCityContextDto.fromJson', () {
    test('lê o contrato multi-cidade preservando ordem e censo agregado', () {
      final context = BudgetCityContextDto.fromJson(const {
        'orc_cidade_id': null,
        'cidade': null,
        'multi_cidade': true,
        'cidades': [
          {
            'id': 297,
            'nome': 'Amapá',
            'censo_ano': 2025,
            'ano_populacao': 2022,
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
        'censo_agregado': {'bercario1ano': 146.33, 'ef1ano': '90.00'},
      });

      expect(context.multiCity, isTrue);
      expect(context.cityIds, [297, 299, 300]);
      expect(context.citiesData, hasLength(3));
      expect(context.censoAgregado['bercario1ano'], 146.33);
      expect(context.censoAgregado['ef1ano'], 90.0);
    });

    test('publica os índices em `indices` e `indicadores`', () {
      final context = BudgetCityContextDto.fromJson(const {
        'cidades': [
          {
            'id': 297,
            'nome': 'Amapá',
            'indices': [
              {'id': 1, 'nome_etapa': 'bercario1ano', 'valor': 30},
            ],
          },
        ],
      });

      final cidade = context.citiesData.single;
      expect(cidade['indices'], hasLength(1));
      expect(cidade['indicadores'], hasLength(1));
    });

    test('não classifica pela quantidade de cidades sem `multi_cidade`', () {
      final context = BudgetCityContextDto.fromJson(const {
        'cidades': [
          {'id': 297, 'nome': 'Amapá'},
          {'id': 299, 'nome': 'Calçoene'},
        ],
      });

      expect(context.multiCity, isNull);
      expect(context.cityIds, [297, 299]);
    });

    test('sem `multi_cidade`, deriva de `orc_cidade_id` nulo', () {
      final multi = BudgetCityContextDto.fromJson(const {
        'orc_cidade_id': null,
        'cidades': [
          {'id': 297, 'nome': 'Amapá'},
        ],
      });
      final unica = BudgetCityContextDto.fromJson(const {'orc_cidade_id': 299});

      expect(multi.multiCity, isTrue);
      expect(unica.multiCity, isFalse);
    });

    test('trata o array vazio que o PHP emite no lugar de um mapa sem chaves',
        () {
      final context = BudgetCityContextDto.fromJson(const {
        'cidades': <dynamic>[],
        'censo_agregado': <dynamic>[],
        'orc_cidade_id': 299,
      });

      expect(context.censoAgregado, isEmpty);
      expect(context.cityIds, [299]);
    });

    test('cai para a cidade singular do contrato legado', () {
      final context = BudgetCityContextDto.fromJson(const {
        'orc_cidade_id': 299,
        'cidade': {
          'idCidades': 299,
          'nome_cidade': 'Calçoene',
          'censo_ano': 2025,
          'cidades_has_indice_etapa': [
            {'idindice_etapa': 1, 'nome_etapa': 'bercario1ano'},
          ],
        },
      });

      expect(context.cityIds, [299]);
      expect(context.citiesData.single['nome'], 'Calçoene');
      expect(context.citiesData.single['censo_ano'], 2025);
      expect(context.citiesData.single['indices'], hasLength(1));
    });

    test('cai para o ID quando só `orc_cidade_id` está presente', () {
      final context =
          BudgetCityContextDto.fromJson(const {'orc_cidade_id': '299'});

      expect(context.cityIds, [299]);
      expect(context.citiesData.single['nome'], 'Cidade 299');
      expect(context.citiesData.single['indices'], isEmpty);
    });

    test('ignora cidades duplicadas e com ID inválido', () {
      final context = BudgetCityContextDto.fromJson(const {
        'cidades': [
          {'id': 297},
          {'id': 297},
          {'id': 0},
          {'id': null},
          'não é um mapa',
          {'cidade_id': '300'},
        ],
      });

      expect(context.cityIds, [297, 300]);
    });

    test('devolve contexto vazio quando não há nenhuma cidade', () {
      final context = BudgetCityContextDto.fromJson(const {
        'orc_cidade_id': null,
        'cidade': null,
      });

      expect(context.cityIds, isEmpty);
      expect(context.citiesData, isEmpty);
      expect(context.censoAgregado, isEmpty);
      expect(context.multiCity, isTrue);
    });
  });
}
