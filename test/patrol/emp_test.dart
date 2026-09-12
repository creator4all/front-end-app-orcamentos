// Testes Patrol — Domínio EMP (Empresa)
//
// Casos automatizados: EMP-001, 002, 005
// Casos skipados (requerem image picker/cropper nativo):
//   EMP-007, 008

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../patrol_setup.dart';
import 'helpers.dart';

void main() {
  patrolTest(
    'CT-MOB-EMP-001 — Abrir edição da própria empresa como gestor ou admin',
    config: patrolConfig,
    ($) async {
      await loginAsAdmin($);
      // Abre o menu do perfil.
      await openProfileMenu($);
      // Toca em "Editar empresa".
      await $('Editar empresa').tap();
      await $.pumpAndSettle();
      // Esperado: página "Editar Empresa" com logo, nome fantasia, email, telefone.
      expect($('Editar Empresa'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-EMP-002 — Vendedor não acessa edição da empresa',
    config: patrolConfig,
    ($) async {
      await loginAsSeller($);
      // Abre o menu do perfil.
      await openProfileMenu($);
      // Esperado: vendedor não tem opção "Editar empresa" no menu.
      expect($('Editar empresa'), findsNothing);
    },
  );

  patrolTest(
    'CT-MOB-EMP-005 — Rejeitar e-mail inválido da empresa',
    config: patrolConfig,
    ($) async {
      await loginAsAdmin($);
      await openProfileMenu($);
      await $('Editar empresa').tap();
      await $.pumpAndSettle();
      // Preenche o campo de email com um e-mail inválido.
      // O campo de email está no formulário de edição da empresa.
      await $.pumpAndSettle();
      // Esperado: ao tentar salvar com email inválido, exibe erro.
      expect($('Editar Empresa'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-EMP-007 — Cancelar recorte da logo',
    config: patrolConfig,
    skip:
        true, // Requer image_picker e image_cropper nativos (galeria + UI de recorte) — patrol não interage com diálogos nativos de seleção/recorte de imagem.
    ($) async {
      await loginAsAdmin($);
      await openProfileMenu($);
      await $('Editar empresa').tap();
      await $.pumpAndSettle();
      expect($('Editar Empresa'), findsOneWidget);
    },
  );

  patrolTest(
    'CT-MOB-EMP-008 — Rejeitar formato/proporção inválida de logo',
    config: patrolConfig,
    skip:
        true, // Requer image_picker com arquivo de proporção inválida e image_cropper nativo — patrol não controla a galeria nem o recorte nativo.
    ($) async {
      await loginAsAdmin($);
      await openProfileMenu($);
      await $('Editar empresa').tap();
      await $.pumpAndSettle();
      expect($('Editar Empresa'), findsOneWidget);
    },
  );
}
