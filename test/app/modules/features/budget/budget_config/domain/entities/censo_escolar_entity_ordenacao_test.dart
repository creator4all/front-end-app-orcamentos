import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_escolar_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_group_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/censo_title_entity.dart';
import 'package:multimidiaapp/app/shared/domain/value_objects/fractional_order.dart';

CensoTitleEntity _titulo(String nomeEtapa, String ordem, {int grupoId = 1}) {
  return CensoTitleEntity(
    id: nomeEtapa.hashCode,
    nomeEtapa: nomeEtapa,
    tituloExibicao: nomeEtapa,
    valor: 100,
    isProfessores: false,
    grupoId: grupoId,
    ordem: FractionalOrder.parse(ordem),
  );
}

CensoEscolarEntity _censo(List<CensoGroupEntity> grupos) {
  return CensoEscolarEntity(
    cidadeId: 10,
    cidadeNome: 'Cidade A',
    grupos: grupos,
    valoresPorEtapa: const {},
  );
}

void main() {
  group('CensoEscolarEntity.gruposOrdenados', () {
    test('ordena os índices pelo ind_ordem dentro de cada grupo', () {
      final censo = _censo([
        CensoGroupEntity(
          id: 1,
          nome: 'Infantil',
          ordem: FractionalOrder.parse('1.00000000'),
          titulos: [
            _titulo('bercario1ano', '1.00000000'),
            _titulo('bercario2anos', '2.00000000'),
            _titulo('maternal', '3.00000000'),
            _titulo('in5ano', '5.00000000'),
            _titulo('in4ano', '4.00000000'),
          ],
        ),
      ]);

      expect(
        censo.gruposOrdenados.single.titulos.map((t) => t.nomeEtapa).toList(),
        ['bercario1ano', 'bercario2anos', 'maternal', 'in4ano', 'in5ano'],
      );
    });

    test('ordena os grupos por grupo_ordem', () {
      final censo = _censo([
        CensoGroupEntity(
          id: 2,
          nome: 'Ensino Fundamental',
          ordem: FractionalOrder.parse('2.00000000'),
          titulos: [_titulo('ef1ano', '1.00000000', grupoId: 2)],
        ),
        CensoGroupEntity(
          id: 1,
          nome: 'Infantil',
          ordem: FractionalOrder.parse('1.00000000'),
          titulos: [_titulo('in4ano', '1.00000000')],
        ),
      ]);

      expect(
        censo.gruposOrdenados.map((g) => g.nome).toList(),
        ['Infantil', 'Ensino Fundamental'],
      );
    });

    test('sem ordem, preserva a ordem de chegada do payload (sort estável)',
        () {
      final censo = _censo([
        CensoGroupEntity(
          id: 1,
          nome: 'Infantil',
          titulos: [
            _titulo('in5ano', '0'),
            _titulo('in4ano', '0'),
          ],
        ),
      ]);

      expect(
        censo.gruposOrdenados.single.titulos.map((t) => t.nomeEtapa).toList(),
        ['in5ano', 'in4ano'],
      );
    });

    test('nunca ordena pelo texto do título', () {
      final censo = _censo([
        CensoGroupEntity(
          id: 1,
          nome: 'Infantil',
          ordem: FractionalOrder.parse('1.00000000'),
          titulos: [
            CensoTitleEntity(
              id: 1,
              nomeEtapa: 'zzz',
              tituloExibicao: 'Zebra',
              valor: 1,
              isProfessores: false,
              grupoId: 1,
              ordem: FractionalOrder.parse('1.00000000'),
            ),
            CensoTitleEntity(
              id: 2,
              nomeEtapa: 'aaa',
              tituloExibicao: 'Abacate',
              valor: 1,
              isProfessores: false,
              grupoId: 1,
              ordem: FractionalOrder.parse('2.00000000'),
            ),
          ],
        ),
      ]);

      expect(
        censo.gruposOrdenados.single.titulos
            .map((t) => t.tituloExibicao)
            .toList(),
        ['Zebra', 'Abacate'],
      );
    });

    test('não altera a lista original de grupos', () {
      final titulos = [
        _titulo('in5ano', '5.00000000'),
        _titulo('in4ano', '4.00000000'),
      ];
      final censo = _censo([
        CensoGroupEntity(id: 1, nome: 'Infantil', titulos: titulos),
      ]);

      censo.gruposOrdenados;

      expect(titulos.map((t) => t.nomeEtapa).toList(), ['in5ano', 'in4ano']);
    });
  });

  group('CensoEscolarEntity - anos do agregado', () {
    test('faixaDeAnos devolve (ano, null) quando todas as cidades coincidem',
        () {
      expect(CensoEscolarEntity.faixaDeAnos([2025, 2025, 2025]), (2025, null));
    });

    test('faixaDeAnos devolve (menor, maior) quando divergem', () {
      expect(CensoEscolarEntity.faixaDeAnos([2026, 2025, 2025]), (2025, 2026));
    });

    test('faixaDeAnos ignora nulos', () {
      expect(CensoEscolarEntity.faixaDeAnos([null, 2025, null]), (2025, null));
    });

    test('faixaDeAnos devolve (null, null) quando nenhuma cidade informou', () {
      expect(CensoEscolarEntity.faixaDeAnos([null, null]), (null, null));
      expect(CensoEscolarEntity.faixaDeAnos(const <int?>[]), (null, null));
    });

    test('label mostra o ano único sem virar intervalo degenerado', () {
      final censo = CensoEscolarEntity(
        cidadeId: 0,
        cidadeNome: 'Agregado',
        censoAno: 2025,
        anoPopulacao: 2025,
        grupos: const [],
        valoresPorEtapa: const {},
      );

      expect(censo.censoAnoLabel, '2025');
      expect(censo.anoPopulacaoLabel, '2025');
    });

    test('label mostra intervalo quando as cidades divergem', () {
      final censo = CensoEscolarEntity(
        cidadeId: 0,
        cidadeNome: 'Agregado',
        censoAno: 2025,
        censoAnoFinal: 2026,
        anoPopulacao: 2024,
        anoPopulacaoFinal: 2025,
        grupos: const [],
        valoresPorEtapa: const {},
      );

      expect(censo.censoAnoLabel, '2025–2026');
      expect(censo.anoPopulacaoLabel, '2024–2025');
    });

    test('label é null quando nenhum ano foi informado', () {
      final censo = CensoEscolarEntity(
        cidadeId: 0,
        cidadeNome: 'Agregado',
        grupos: const [],
        valoresPorEtapa: const {},
      );

      expect(censo.censoAnoLabel, isNull);
      expect(censo.anoPopulacaoLabel, isNull);
    });
  });
}
