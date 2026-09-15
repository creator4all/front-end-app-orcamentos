import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_escolar_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_group_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_title_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/services/censo_escolar_mapper.dart';
import 'package:multimidiaapp/app/shared/domain/value_objects/fractional_order.dart';

Map<String, dynamic> _city({
  required int id,
  required String nome,
  required List<Map<String, dynamic>> indices,
}) {
  return <String, dynamic>{
    'id': id,
    'nome': nome,
    'indices': indices,
  };
}

Map<String, dynamic> _indice({
  required int id,
  required String nomeEtapa,
  required String titulo,
  required double valor,
  required int grupoId,
  required String grupoNome,
  required String indOrdem,
  required String grupoOrdem,
}) {
  return <String, dynamic>{
    'id': id,
    'nome_etapa': nomeEtapa,
    'titulo': titulo,
    'valor': valor,
    'ind_ordem': indOrdem,
    'grupo': {
      'id': grupoId,
      'nome': grupoNome,
      'ordem': grupoOrdem,
    },
  };
}

void main() {
  const mapper = CensoEscolarMapper();

  group('CensoEscolarMapper.buildAggregatedCenso - ordenação', () {
    test('ordena grupos por grupo.ordem e títulos por ind_ordem', () {
      final censo = mapper.buildAggregatedCenso(
        censoAgregado: {'ef1ano': 100.0, 'ef2ano': 50.0},
        citiesData: [
          _city(
            id: 1,
            nome: 'Cidade A',
            indices: [
              _indice(
                id: 10,
                nomeEtapa: 'ef2ano',
                titulo: '2º ano',
                valor: 50.0,
                grupoId: 3,
                grupoNome: 'Fundamental',
                indOrdem: '2.00000000',
                grupoOrdem: '5.00000000',
              ),
              _indice(
                id: 11,
                nomeEtapa: 'ef1ano',
                titulo: '1º ano',
                valor: 100.0,
                grupoId: 3,
                grupoNome: 'Fundamental',
                indOrdem: '1.00000000',
                grupoOrdem: '5.00000000',
              ),
            ],
          ),
        ],
      );

      expect(censo.grupos.single.id, 3);
      expect(censo.grupos.single.nome, 'Fundamental');
      expect(censo.grupos.single.titulos.map((t) => t.nomeEtapa).toList(),
          ['ef1ano', 'ef2ano']);
    });

    test(
        'ordena grupos por grupo.ordem mesmo quando a primeira cidade envia fora de ordem',
        () {
      final censo = mapper.buildAggregatedCenso(
        censoAgregado: {'ef1ano': 100.0, 'inf1': 30.0},
        citiesData: [
          _city(
            id: 1,
            nome: 'Cidade A',
            indices: [
              _indice(
                id: 10,
                nomeEtapa: 'ef1ano',
                titulo: '1º ano EF',
                valor: 100.0,
                grupoId: 3,
                grupoNome: 'Fundamental',
                indOrdem: '1.00000000',
                grupoOrdem: '5.00000000',
              ),
              _indice(
                id: 20,
                nomeEtapa: 'inf1',
                titulo: '1º ano Infantil',
                valor: 30.0,
                grupoId: 1,
                grupoNome: 'Infantil',
                indOrdem: '1.00000000',
                grupoOrdem: '1.00000000',
              ),
            ],
          ),
        ],
      );

      expect(censo.grupos.map((g) => g.id).toList(), [1, 3]);
      expect(censo.grupos.first.nome, 'Infantil');
      expect(censo.grupos.last.nome, 'Fundamental');
    });
  });

  group('CensoEscolarMapper.buildAggregatedCenso - agregado por união', () {
    test(
        'item 1: não cria grupo vazio quando a mesma etapa aparece em grupos diferentes entre cidades',
        () {
      final censo = mapper.buildAggregatedCenso(
        censoAgregado: {'ef1ano': 100.0, 'ef2ano': 50.0},
        citiesData: [
          _city(
            id: 1,
            nome: 'Cidade A',
            indices: [
              _indice(
                id: 10,
                nomeEtapa: 'ef1ano',
                titulo: '1º ano',
                valor: 100.0,
                grupoId: 3,
                grupoNome: 'Fundamental',
                indOrdem: '1.00000000',
                grupoOrdem: '5.00000000',
              ),
            ],
          ),
          _city(
            id: 2,
            nome: 'Cidade B',
            indices: [
              _indice(
                id: 10,
                nomeEtapa: 'ef1ano',
                titulo: '1º ano',
                valor: 100.0,
                grupoId: 5,
                grupoNome: 'EJA',
                indOrdem: '1.00000000',
                grupoOrdem: '9.00000000',
              ),
              _indice(
                id: 11,
                nomeEtapa: 'ef2ano',
                titulo: '2º ano',
                valor: 50.0,
                grupoId: 5,
                grupoNome: 'EJA',
                indOrdem: '2.00000000',
                grupoOrdem: '9.00000000',
              ),
            ],
          ),
        ],
      );

      // Dedup é por grupo+etapa: ef1ano entra nos dois grupos e o grupo 5
      // ainda recebe ef2ano. Nenhum grupo fica vazio.
      expect(censo.grupos.length, 2);
      expect(censo.grupos.map((g) => g.id).toSet(), {3, 5});
      for (final grupo in censo.grupos) {
        expect(grupo.titulos, isNotEmpty,
            reason: 'grupo ${grupo.id} não deve estar vazio');
      }
    });

    test('índices exclusivos de cidade secundária aparecem no agregado', () {
      final censo = mapper.buildAggregatedCenso(
        censoAgregado: {'ef1ano': 100.0, 'ef2ano': 50.0, 'inf1': 30.0},
        citiesData: [
          _city(
            id: 1,
            nome: 'Cidade A',
            indices: [
              _indice(
                id: 10,
                nomeEtapa: 'ef1ano',
                titulo: '1º ano',
                valor: 100.0,
                grupoId: 3,
                grupoNome: 'Fundamental',
                indOrdem: '1.00000000',
                grupoOrdem: '5.00000000',
              ),
            ],
          ),
          _city(
            id: 2,
            nome: 'Cidade B',
            indices: [
              _indice(
                id: 11,
                nomeEtapa: 'ef2ano',
                titulo: '2º ano',
                valor: 50.0,
                grupoId: 3,
                grupoNome: 'Fundamental',
                indOrdem: '2.00000000',
                grupoOrdem: '5.00000000',
              ),
              _indice(
                id: 20,
                nomeEtapa: 'inf1',
                titulo: '1º ano Infantil',
                valor: 30.0,
                grupoId: 1,
                grupoNome: 'Infantil',
                indOrdem: '1.00000000',
                grupoOrdem: '1.00000000',
              ),
            ],
          ),
        ],
      );

      final todasEtapas =
          censo.grupos.expand((g) => g.titulos).map((t) => t.nomeEtapa).toSet();
      expect(todasEtapas, {'ef1ano', 'ef2ano', 'inf1'});
    });
  });

  group('CensoEscolarMapper.buildAggregatedCenso - ordem do grupo', () {
    test(
        'item 2: primeira ordem não-zero vence — cidade sem ordem não sobrescreve',
        () {
      final censo = mapper.buildAggregatedCenso(
        censoAgregado: {'ef1ano': 100.0, 'inf1': 30.0},
        citiesData: [
          _city(
            id: 1,
            nome: 'Cidade A',
            indices: [
              _indice(
                id: 10,
                nomeEtapa: 'ef1ano',
                titulo: '1º ano EF',
                valor: 100.0,
                grupoId: 3,
                grupoNome: 'Fundamental',
                indOrdem: '1.00000000',
                grupoOrdem: '5.00000000',
              ),
              _indice(
                id: 20,
                nomeEtapa: 'inf1',
                titulo: '1º ano Infantil',
                valor: 30.0,
                grupoId: 1,
                grupoNome: 'Infantil',
                indOrdem: '1.00000000',
                grupoOrdem: '1.00000000',
              ),
            ],
          ),
          _city(
            id: 2,
            nome: 'Cidade B',
            indices: [
              _indice(
                id: 10,
                nomeEtapa: 'ef1ano',
                titulo: '1º ano EF',
                valor: 100.0,
                grupoId: 3,
                grupoNome: 'Fundamental',
                indOrdem: '1.00000000',
                grupoOrdem: '', // cidade B não envia ordem do grupo
              ),
            ],
          ),
        ],
      );

      // Fundamental deve manter ordem 5 (da cidade A), não zero (da cidade B).
      expect(censo.grupos.first.id, 1);
      expect(censo.grupos.first.nome, 'Infantil');
      expect(censo.grupos.last.id, 3);
      expect(censo.grupos.last.nome, 'Fundamental');
      expect(censo.grupos.last.ordem.toJson(), '5');
    });
  });

  group('CensoEscolarMapper.buildCensoFromCityData - tryParse', () {
    test('item 5: ind_ordem vazio não lança, vira FractionalOrder.zero', () {
      final cityData = _city(
        id: 1,
        nome: 'Cidade A',
        indices: [
          {
            'id': 10,
            'nome_etapa': 'ef1ano',
            'titulo': '1º ano',
            'valor': 100.0,
            'ind_ordem': '',
            'grupo': {
              'id': 3,
              'nome': 'Fundamental',
              'ordem': '',
            },
          },
        ],
      );

      final censo = mapper.buildCensoFromCityData(cityData);

      expect(censo, isNotNull);
      expect(censo!.grupos.single.ordem, FractionalOrder.zero);
      expect(censo.grupos.single.titulos.single.ordem, FractionalOrder.zero);
    });

    test('ind_ordem nulo não lança', () {
      final cityData = _city(
        id: 1,
        nome: 'Cidade A',
        indices: [
          {
            'id': 10,
            'nome_etapa': 'ef1ano',
            'titulo': '1º ano',
            'valor': 100.0,
            'ind_ordem': null,
            'grupo': {
              'id': 3,
              'nome': 'Fundamental',
              'ordem': null,
            },
          },
        ],
      );

      final censo = mapper.buildCensoFromCityData(cityData);

      expect(censo, isNotNull);
      expect(censo!.grupos.single.ordem, FractionalOrder.zero);
    });
  });

  group('CensoEscolarMapper.calculateAggregatedCensoFromCities', () {
    test('soma valores da mesma etapa entre cidades', () {
      final result = mapper.calculateAggregatedCensoFromCities(
        [
          _city(
            id: 1,
            nome: 'A',
            indices: [
              _indice(
                id: 10,
                nomeEtapa: 'ef1ano',
                titulo: '1º ano',
                valor: 100.0,
                grupoId: 3,
                grupoNome: 'Fundamental',
                indOrdem: '1.00000000',
                grupoOrdem: '5.00000000',
              ),
            ],
          ),
          _city(
            id: 2,
            nome: 'B',
            indices: [
              _indice(
                id: 10,
                nomeEtapa: 'ef1ano',
                titulo: '1º ano',
                valor: 50.0,
                grupoId: 3,
                grupoNome: 'Fundamental',
                indOrdem: '1.00000000',
                grupoOrdem: '5.00000000',
              ),
            ],
          ),
        ],
        {},
      );

      expect(result['ef1ano'], 150.0);
    });

    test('retorna fallback quando não há dados', () {
      final result = mapper.calculateAggregatedCensoFromCities(
        [],
        {'ef1ano': 100.0},
      );

      expect(result['ef1ano'], 100.0);
    });
  });

  group('CensoEscolarMapper.updateCityDataWithCenso - propagação de ordem', () {
    test('item 4: buildIndicadoresFromIndices propaga ind_ordem e grupo_ordem',
        () {
      final censo = CensoEscolarEntity(
        cidadeId: 1,
        cidadeNome: 'Cidade A',
        grupos: [
          CensoGroupEntity(
            id: 3,
            nome: 'Fundamental',
            ordem: FractionalOrder.parse('5.00000000'),
            titulos: [
              CensoTitleEntity(
                id: 10,
                nomeEtapa: 'ef1ano',
                tituloExibicao: '1º ano',
                valor: 100.0,
                isProfessores: false,
                grupoId: 3,
                ordem: FractionalOrder.parse('1.00000000'),
              ),
            ],
          ),
        ],
        valoresPorEtapa: const {'ef1ano': 100.0},
      );

      final updated = mapper.updateCityDataWithCenso({}, censo);

      final indicadores = updated['indicadores'] as List<Map<String, dynamic>>;
      expect(indicadores.single['ind_ordem'], isNotNull);
      expect(indicadores.single['grupo_ordem'], isNotNull);
    });
  });

  group('CensoEscolarMapper.buildAggregatedCenso - dedup por grupo+etapa', () {
    test(
        'mesma nome_etapa em grupos diferentes mantém os dois grupos com seus títulos',
        () {
      final censo = mapper.buildAggregatedCenso(
        censoAgregado: {'ef1ano': 100.0},
        citiesData: [
          _city(
            id: 1,
            nome: 'Cidade A',
            indices: [
              _indice(
                id: 10,
                nomeEtapa: 'ef1ano',
                titulo: '1º ano',
                valor: 100.0,
                grupoId: 3,
                grupoNome: 'Fundamental',
                indOrdem: '1.00000000',
                grupoOrdem: '5.00000000',
              ),
            ],
          ),
          _city(
            id: 2,
            nome: 'Cidade B',
            indices: [
              _indice(
                id: 10,
                nomeEtapa: 'ef1ano',
                titulo: '1º ano',
                valor: 100.0,
                grupoId: 7,
                grupoNome: 'EJA',
                indOrdem: '1.00000000',
                grupoOrdem: '9.00000000',
              ),
            ],
          ),
        ],
      );

      expect(censo.grupos.map((g) => g.nome).toList(), ['Fundamental', 'EJA']);
      for (final grupo in censo.grupos) {
        expect(grupo.titulos.single.nomeEtapa, 'ef1ano',
            reason: 'grupo ${grupo.nome} perdeu o título no dedup');
      }
    });

    test('a mesma etapa repetida no mesmo grupo continua entrando uma só vez',
        () {
      final censo = mapper.buildAggregatedCenso(
        censoAgregado: {'ef1ano': 300.0},
        citiesData: [
          for (var i = 1; i <= 2; i++)
            _city(
              id: i,
              nome: 'Cidade $i',
              indices: [
                _indice(
                  id: 10,
                  nomeEtapa: 'ef1ano',
                  titulo: '1º ano',
                  valor: 150.0,
                  grupoId: 3,
                  grupoNome: 'Fundamental',
                  indOrdem: '1.00000000',
                  grupoOrdem: '5.00000000',
                ),
              ],
            ),
        ],
      );

      expect(censo.grupos.single.titulos.length, 1);
      expect(censo.grupos.single.titulos.single.valor, 300.0);
    });

    test('códigos distintos como ef1ano e em1ano nunca colidem', () {
      final censo = mapper.buildAggregatedCenso(
        censoAgregado: {'ef1ano': 100.0, 'em1ano': 40.0},
        citiesData: [
          _city(
            id: 1,
            nome: 'Cidade A',
            indices: [
              _indice(
                id: 10,
                nomeEtapa: 'ef1ano',
                titulo: '1º Ano',
                valor: 100.0,
                grupoId: 3,
                grupoNome: 'Ensino Fundamental',
                indOrdem: '1.00000000',
                grupoOrdem: '2.00000000',
              ),
              _indice(
                id: 20,
                nomeEtapa: 'em1ano',
                titulo: '1º Ano',
                valor: 40.0,
                grupoId: 4,
                grupoNome: 'Ensino Médio',
                indOrdem: '1.00000000',
                grupoOrdem: '3.00000000',
              ),
            ],
          ),
        ],
      );

      expect(censo.grupos.map((g) => g.nome).toList(),
          ['Ensino Fundamental', 'Ensino Médio']);
      expect(
        censo.grupos.expand((g) => g.titulos).map((t) => t.nomeEtapa).toList(),
        ['ef1ano', 'em1ano'],
      );
    });
  });

  group('CensoEscolarMapper.buildAggregatedCenso - anos', () {
    Map<String, dynamic> cidadeComAnos(int id, int? censoAno, int? anoPop) {
      final c = _city(
        id: id,
        nome: 'Cidade $id',
        indices: [
          _indice(
            id: 10,
            nomeEtapa: 'ef1ano',
            titulo: '1 ano',
            valor: 10.0,
            grupoId: 3,
            grupoNome: 'Fundamental',
            indOrdem: '1.00000000',
            grupoOrdem: '1.00000000',
          ),
        ],
      );
      if (censoAno != null) c['censo_ano'] = censoAno;
      if (anoPop != null) c['ano_populacao'] = anoPop;
      return c;
    }

    test('usa o ano único quando todas as cidades coincidem', () {
      final censo = mapper.buildAggregatedCenso(
        censoAgregado: {'ef1ano': 30.0},
        citiesData: [
          cidadeComAnos(1, 2025, 2025),
          cidadeComAnos(2, 2025, 2025),
        ],
      );

      expect(censo.censoAnoLabel, '2025');
      expect(censo.anoPopulacaoLabel, '2025');
    });

    test('usa intervalo quando as cidades divergem', () {
      final censo = mapper.buildAggregatedCenso(
        censoAgregado: {'ef1ano': 30.0},
        citiesData: [
          cidadeComAnos(1, 2025, 2024),
          cidadeComAnos(2, 2026, 2025),
        ],
      );

      expect(censo.censoAnoLabel, '2025–2026');
      expect(censo.anoPopulacaoLabel, '2024–2025');
    });

    test('ignora cidades sem ano informado', () {
      final censo = mapper.buildAggregatedCenso(
        censoAgregado: {'ef1ano': 30.0},
        citiesData: [
          cidadeComAnos(1, null, null),
          cidadeComAnos(2, 2025, 2025),
        ],
      );

      expect(censo.censoAnoLabel, '2025');
    });

    test('fica sem rótulo quando nenhuma cidade informou o ano', () {
      final censo = mapper.buildAggregatedCenso(
        censoAgregado: {'ef1ano': 30.0},
        citiesData: [cidadeComAnos(1, null, null)],
      );

      expect(censo.censoAnoLabel, isNull);
      expect(censo.anoPopulacaoLabel, isNull);
    });

    test('aceita ano como string, formato que o PHP emite', () {
      final cidade = cidadeComAnos(1, null, null);
      cidade['censo_ano'] = '2025';
      cidade['ano_populacao'] = '2025';

      final censo = mapper.buildAggregatedCenso(
        censoAgregado: {'ef1ano': 30.0},
        citiesData: [cidade],
      );

      expect(censo.censoAnoLabel, '2025');
      expect(censo.anoPopulacaoLabel, '2025');
    });
  });
}
