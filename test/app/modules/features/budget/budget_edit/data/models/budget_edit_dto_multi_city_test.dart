import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/data/models/budget_edit_dto.dart';

/// Fatia mínima de `GET /api/orcamentos/novo/{id}`.
///
/// Esse endpoint responde o orçamento na raiz (sem envelope `dados`) e é o
/// mesmo formatador reutilizado pelas respostas de versionamento.
Map<String, dynamic> _multiCityPayload() => {
      'orc_orcamentoId': 3,
      'orc_nome': 'projeto',
      'orc_dias_validade': 60,
      'orc_data_validade': '2026-10-01',
      'orc_status': 'pendente',
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
          'indices': [
            {'id': 1, 'nome_etapa': 'bercario1ano', 'valor': 30},
          ],
        },
        {'id': 299, 'nome': 'Calçoene', 'indices': <dynamic>[]},
        {'id': 300, 'nome': 'Cutias', 'indices': <dynamic>[]},
      ],
      'censo_agregado': {'bercario1ano': 146.33},
      'produtos': <dynamic>[],
      'mapa_indicadores': <String, dynamic>{},
    };

void main() {
  group('BudgetEditDto.fromJson', () {
    test('reconstrói o contexto multi-cidade ao reabrir o orçamento', () {
      final dto = BudgetEditDto.fromJson(_multiCityPayload());

      expect(dto.cityIds, [297, 299, 300]);
      expect(dto.citiesDataRaw, hasLength(3));
      expect(dto.censoAgregado, isNotEmpty);
      expect(dto.multiCity, isTrue);
      expect(dto.isArchived, isTrue);
      expect(dto.toEntity().isMultiCity, isTrue);
    });

    test('preserva o estado de arquivamento persistido', () {
      final payload = _multiCityPayload()..['orc_is_archived'] = false;

      expect(BudgetEditDto.fromJson(payload).isArchived, isFalse);
    });

    test('mantém multi-cidade quando só uma cidade está vinculada', () {
      final payload = _multiCityPayload()
        ..['cidades'] = [
          {'id': 297, 'nome': 'Amapá', 'indices': <dynamic>[]},
        ];

      final entity = BudgetEditDto.fromJson(payload).toEntity();

      expect(entity.cityIds, [297]);
      expect(entity.isMultiCity, isTrue);
    });

    test('mantém o contrato legado de cidade única', () {
      final dto = BudgetEditDto.fromJson({
        'orc_orcamentoId': 4,
        'orc_dias_validade': 30,
        'orc_status': 'pendente',
        'orc_total': 0,
        'orc_usuario_id': 1,
        'orc_cidade_id': 299,
        'multi_cidade': false,
        'cidade': {'idCidades': 299, 'nome_cidade': 'Calçoene'},
        'produtos': <dynamic>[],
      });

      expect(dto.cityIds, [299]);
      expect(dto.multiCity, isFalse);
      expect(dto.toEntity().isMultiCity, isFalse);
    });
  });
}
