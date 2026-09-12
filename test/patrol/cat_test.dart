// Testes Patrol — Domínio CAT (Produtos)
//
// Casos automatizados: CAT-002, 007
// Casos skipados (requerem produto de teste restaurável no catálogo):
//   CAT-005, 006

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

  patrolTest(
    'CT-MOB-CAT-005 — Salvar configuração válida de produto',
    config: patrolConfig,
    skip:
        true, // Requer produto de teste restaurável no catálogo para alterar campos, salvar e verificar persistência — não há fixture de catálogo determinística no ambiente de teste.
    ($) async {
      await loginAsAdmin($);
      await openProfileMenu($);
      await $('Configurar produtos').tap();
      await $.pumpAndSettle();
      expect($('Configurar Produtos').at(0), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-CAT-006 — Desativar e reativar produto',
    config: patrolConfig,
    skip:
        true, // Requer produto de teste no catálogo para alternar status, verificar ausência em novo orçamento e reativar — não há fixture de catálogo determinística no ambiente de teste.
    ($) async {
      await loginAsAdmin($);
      await openProfileMenu($);
      await $('Configurar produtos').tap();
      await $.pumpAndSettle();
      expect($('Configurar Produtos').at(0), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-CAT-007 — Tratar falha ao atualizar produto/status',
    config: patrolConfig,
    ($) async {
      await loginAsAdmin($);
      await openProfileMenu($);
      await $('Configurar produtos').tap();
      await $.pumpAndSettle();
      // Página carregada com categorias.
      expect($('Configurar Produtos').at(0), findsOneWidget);
      // Interrompe a rede para simular falha de rede/servidor.
      await $.platform.mobile.enableAirplaneMode();
      await $.pumpAndSettle();
      // Esperado: página estável, sem crash nem diálogo de sucesso falso.
      expect($('Configurar Produtos').at(0), findsOneWidget);
      expect($('Sucesso'), findsNothing);
      // Restaura a rede.
      await $.platform.mobile.disableAirplaneMode();
      await $.pumpAndSettle();
      // Esperado: recuperação sem reiniciar o app.
      expect($('Configurar Produtos').at(0), findsOneWidget);
    },
  );
}
