import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/auth/presentation/stores/auth_store.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/presentation/widgets/school_census_card.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/domain/entities/budget_edit_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/presentation/pages/edit_budget_page.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_edit/presentation/stores/budget_edit_store.dart';
import 'package:multimidiaapp/app/modules/features/budget/shared/errors/budget_failure.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_top_bar.dart';
import 'package:multimidiaapp/theme/app_theme.dart';

import '../../budget_edit_test_fixture.dart';

class _Harness {
  final BudgetEditTestRepository repository;
  late final BudgetEditTestStore store = BudgetEditTestStore(repository);
  Object? result;
  int returns = 0;
  final showEditor = ValueNotifier(true);

  _Harness(BudgetEditEntity budget)
      : repository = BudgetEditTestRepository(budget);
}

class _EditTestModule extends Module {
  final _Harness harness;

  _EditTestModule(this.harness);

  @override
  List<Bind> get binds => [
        Bind.instance<BudgetEditStore>(harness.store),
        Bind.instance<AuthStore>(FakeAuthStore()),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/',
            child: (_, __) => Scaffold(
                  body: TextButton(
                    onPressed: () async {
                      harness.result = await Modular.to.pushNamed('/edit');
                      harness.returns++;
                    },
                    child: const Text('Abrir orçamento'),
                  ),
                )),
        ChildRoute('/edit',
            child: (_, __) => ValueListenableBuilder<bool>(
                  valueListenable: harness.showEditor,
                  builder: (_, showEditor, __) => showEditor
                      ? const EditBudgetPage(budgetId: 1)
                      : const Scaffold(body: Text('Página externa')),
                )),
        ChildRoute('/budget/census/:id', child: (_, args) {
          final callbacks = args.data as Map<String, dynamic>;
          return Scaffold(
            body: TextButton(
              onPressed: () async {
                harness.repository.censusWrites++;
                callbacks['onCensusUpdated'](changedCensus());
                await callbacks['onCensusSaved']();
                Modular.to.pop(true);
              },
              child: const Text('Confirmar censo de teste'),
            ),
          );
        }),
      ];
}

Future<_Harness> _open(WidgetTester tester, {BudgetEditEntity? budget}) async {
  tester.view.physicalSize = const Size(430 * 3, 932 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
  Modular.setInitialRoute('/');
  final harness = _Harness(budget ?? editableBudget());
  await tester.pumpWidget(ModularApp(
    module: _EditTestModule(harness),
    child: RepaintBoundary(
      key: const ValueKey('item7-preview'),
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => MaterialApp.router(
          routeInformationParser: Modular.routeInformationParser,
          routerDelegate: Modular.routerDelegate,
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Abrir orçamento'));
  await tester.pumpAndSettle();
  expect(harness.store.hasChanges, isFalse);
  expect(harness.repository.reads, 1);
  return harness;
}

Future<void> _back(WidgetTester tester, {bool system = false}) async {
  if (system) {
    await tester.binding.handlePopRoute();
  } else {
    await tester.tap(find.byIcon(Icons.arrow_back));
  }
  await tester.pumpAndSettle();
}

Future<void> _save(WidgetTester tester) async {
  final button = find.text('Salvar Alterações');
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // Usa a fonte Material distribuída com o SDK, também na captura visual.
    final sdk = Platform.environment['FLUTTER_ROOT']!;
    final font =
        File('$sdk/bin/cache/artifacts/material_fonts/roboto-regular.ttf');
    final loader = FontLoader('Roboto')
      ..addFont(
          font.readAsBytes().then((bytes) => ByteData.sublistView(bytes)));
    await loader.load();
    final icons = File(
        '$sdk/bin/cache/artifacts/material_fonts/materialicons-regular.otf');
    await (FontLoader('MaterialIcons')
          ..addFont(
              icons.readAsBytes().then((bytes) => ByteData.sublistView(bytes))))
        .load();
  });

  for (final system in [false, true]) {
    testWidgets('sem alterações retorna false uma vez, sistema=$system',
        (tester) async {
      final harness = await _open(tester);
      await _back(tester, system: system);
      expect(find.text('Descartar alterações?'), findsNothing);
      expect(find.byType(EditBudgetPage), findsNothing);
      expect(harness.result, isFalse);
      expect(harness.returns, 1);
      expect(harness.repository.writes, 0);
      expect(harness.store.resets, 2);
    });

    testWidgets('Cancelar preserva e Descartar sai sem gravar, sistema=$system',
        (tester) async {
      final harness = await _open(tester);
      harness.store.setProductManualQuantity(1, 25);
      await _back(tester, system: system);
      expect(find.text('Descartar alterações?'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Descartar'), findsOneWidget);
      const capturePath = String.fromEnvironment('ITEM7_CAPTURE_PATH');
      if (!system && capturePath.isNotEmpty) {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('item7-preview')),
        );
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(capturePath).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(harness.store.product(1).quantidade, 25);
      expect(harness.store.hasChanges, isTrue);
      expect(harness.store.resets, 1);
      expect(harness.repository.reads, 1);
      expect(harness.repository.writes, 0);
      expect(harness.returns, 0);

      await _back(tester, system: system);
      await tester.tap(find.text('Descartar'));
      await tester.pumpAndSettle();
      expect(harness.result, isFalse);
      expect(harness.returns, 1);
      expect(harness.repository.writes, 0);
      expect(harness.store.resets, 2);
      expect(find.byType(EditBudgetPage), findsNothing);
    });
  }

  testWidgets('carga sem validade não preenche nem cria alteração local',
      (tester) async {
    final harness = await _open(tester,
        budget: editableBudget().copyWith(validityDate: null));
    expect(harness.store.validityDate, isNull);
    expect(harness.store.hasChanges, isFalse);
    await _back(tester);
    expect(harness.result, isFalse);
    expect(harness.repository.writes, 0);
  });

  for (final edit in <String, void Function(BudgetEditTestStore)>{
    'seleção': (s) => s.toggleProduct(1, false),
    'preço': (s) => s.updateProductValue(1, 25),
    'indicador': (s) => s.toggleProductIndicator(1, 1),
    'validade': (s) =>
        s.setValidityDate(s.validityDate!.add(const Duration(days: 2))),
  }.entries) {
    testWidgets('${edit.key} local pede confirmação', (tester) async {
      final harness = await _open(tester);
      edit.value(harness.store);
      await _back(tester);
      expect(find.text('Descartar alterações?'), findsOneWidget);
      expect(harness.repository.writes, 0);
      expect(harness.returns, 0);
    });
  }

  testWidgets('desfazer preço e abrir seção dispensa confirmação',
      (tester) async {
    final harness = await _open(tester);
    harness.store.updateProductValue(1, 25);
    harness.store.updateProductValue(1, 10);
    harness.store.selectCategory(harness.store.categories.first);
    await _back(tester);
    expect(harness.result, isFalse);
    expect(harness.returns, 1);
    expect(harness.repository.writes, 0);
  });

  for (final multiCity in [false, true]) {
    for (final status in ['aprovado', 'expirado']) {
      testWidgets('protege $status arquivado, multi=$multiCity',
          (tester) async {
        final harness = await _open(tester,
            budget: editableBudget(
                status: status, archived: true, multiCity: multiCity));
        harness.store.setArchived(false);
        await _back(tester);
        expect(find.text('Descartar alterações?'), findsOneWidget);
        expect(harness.repository.writes, 0);
      });
    }
  }

  for (final localEdit in [false, true]) {
    testWidgets(
        'censo salvo retorna refresh e preserva persistência, dirty=$localEdit',
        (tester) async {
      final harness =
          await _open(tester, budget: editableBudget(multiCity: true));
      if (localEdit) harness.store.setProductManualQuantity(1, 25);
      await tester.tap(find.byType(SchoolCensusCard));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar censo de teste'));
      await tester.pumpAndSettle();
      expect(harness.repository.censusWrites, 1);
      expect(harness.store.product(2).quantidade, 20);
      expect(harness.store.hasChanges, localEdit);
      await _back(tester);
      if (localEdit) {
        expect(harness.store.product(1).quantidade, 25);
        await tester.tap(find.text('Descartar'));
        await tester.pumpAndSettle();
      }
      final result = harness.result as Map<String, dynamic>;
      expect(result['shouldRefresh'], isTrue);
      if (localEdit) {
        expect(result.containsKey('budgetPatch'), isFalse);
      } else {
        expect(result['budgetPatch'], containsPair('id', 1));
        expect(result['budgetPatch'], containsPair('total', 300.0));
      }
      expect(harness.returns, 1);
      expect(harness.repository.censusWrites, 1);
      expect(harness.repository.writes, 0);
    });
  }

  testWidgets('tentativas repetidas e fechar diálogo não descartam',
      (tester) async {
    final harness = await _open(tester);
    harness.store.updateProductValue(1, 25);
    final back =
        tester.widget<CustomTopBar>(find.byType(CustomTopBar)).onBackPressed!;
    back();
    back();
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(harness.returns, 0);
    expect(harness.store.hasChanges, isTrue);
    await _back(tester);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(harness.returns, 0);
    expect(harness.store.hasChanges, isTrue);
    expect(harness.repository.writes, 0);
  });

  testWidgets('Cancelar permite salvar e sair sem outra confirmação',
      (tester) async {
    final harness = await _open(tester);
    harness.store.updateProductValue(1, 25);
    await _back(tester);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    harness.repository.savedState = () => harness.repository.budget.copyWith(
          categoriesData: harness.store.categories.toList(),
          total: harness.store.totalValue,
        );
    await _save(tester);
    expect(find.text('Orçamento atualizado com sucesso!'), findsOneWidget);
    await tester.tap(find.text('Entendi'));
    await tester.pumpAndSettle();
    expect(harness.store.hasChanges, isFalse);
    await _back(tester);
    expect(find.text('Descartar alterações?'), findsNothing);
    expect(harness.result, containsPair('shouldRefresh', true));
    expect(harness.returns, 1);
    expect(harness.repository.writes, 1);
  });

  testWidgets('falha ao salvar mantém edição e confirmação', (tester) async {
    final harness = await _open(tester);
    harness.store.updateProductValue(1, 25);
    harness.repository.saveFailure =
        const ValidationFailure('Falha controlada');
    await _save(tester);
    expect(find.text('Falha controlada'), findsOneWidget);
    await tester.tap(find.text('Entendi'));
    await tester.pumpAndSettle();
    expect(harness.store.hasChanges, isTrue);
    await _back(tester);
    expect(find.text('Descartar alterações?'), findsOneWidget);
    expect(harness.returns, 0);
    expect(harness.repository.writes, 1);
  });

  testWidgets('retorno de confirmação após desmontar não navega novamente',
      (tester) async {
    final harness = await _open(tester);
    harness.store.updateProductValue(1, 25);
    await _back(tester);
    // Substitui a página enquanto o diálogo da rota continua pendente.
    harness.showEditor.value = false;
    await tester.pumpAndSettle();
    expect(find.byType(EditBudgetPage), findsNothing);
    await tester.tap(find.text('Descartar'));
    await tester.pumpAndSettle();
    expect(find.text('Página externa'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(harness.returns, 0);
    expect(harness.store.resets, 2);
    expect(harness.repository.writes, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('não descarta enquanto grava e retorno tardio não usa contexto',
      (tester) async {
    final harness = await _open(tester);
    harness.store.updateProductValue(1, 25);
    harness.repository.saveGate = Completer<void>();
    await tester.ensureVisible(find.text('Salvar Alterações'));
    await tester.tap(find.text('Salvar Alterações'));
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.text('Descartar alterações?'), findsNothing);
    expect(harness.returns, 0);
    await tester.pumpWidget(const SizedBox.shrink());
    harness.repository.saveGate!.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
