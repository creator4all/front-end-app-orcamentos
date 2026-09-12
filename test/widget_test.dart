import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app_module.dart';
import 'package:multimidiaapp/main.dart';
import 'package:multimidiaapp/stores/store_provider.dart';

void main() {
  testWidgets('opens the login screen without a stored session',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(
      ModularApp(
        module: AppModule(),
        child: Builder(
          builder: (_) => StoreProvider(
            child: const MyApp(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Acessar'), findsOneWidget);
    expect(find.text('Cadastrar'), findsOneWidget);
  });
}
