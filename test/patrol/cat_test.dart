// Testes Patrol — Domínio CAT (Produtos)
//
// Cobrem o 1 caso aprovado do relatório MOBILE-RELATORIO-CONSOLIDADO.md:
//   CT-MOB-CAT-002

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'helpers.dart';

void main() {
  patrolTest(
    'CT-MOB-CAT-002 — Listar categorias, subcategorias e produtos (parcial)',
    config: patrolConfig,
    ($) async {
      await loginAsAdmin($);
      // Navega para Configurar Produtos.
      await openProfileMenu($);
      await $('Configurar produtos').tap();
      await $.pumpAndSettle();
      // Esperado: página "Configurar Produtos" com categorias visíveis.
      expect($('Configurar Produtos').at(0), findsOneWidget);
    },
  );
}
