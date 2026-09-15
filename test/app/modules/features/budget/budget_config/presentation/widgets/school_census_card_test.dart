import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/presentation/widgets/school_census_card.dart';
import 'package:multimidiaapp/app/modules/features/budget/shared/models/budget_city_context_dto.dart';

/// Monta o card no shape que o backend entrega em `cidades`.
Widget _host({
  required int numberOfCities,
  required List<Map<String, dynamic>> citiesData,
  Map<String, double>? censoAgregado,
}) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, __) => MaterialApp(
      home: Scaffold(
        body: SchoolCensusCard(
          numberOfCities: numberOfCities,
          citiesData: citiesData,
          censoAgregado: censoAgregado,
        ),
      ),
    ),
  );
}

void main() {
  // O card é dimensionado por ScreenUtil: sem uma superfície de telefone a
  // linha de indicadores estoura o Flex e o teste falha por layout.
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.physicalSize = const Size(430 * 3, 932 * 3);
    view.devicePixelRatio = 3.0;
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  /// Payload de `GET /api/orcamentos/{id}` com três cidades, passado pelo
  /// mesmo parser que alimenta a página.
  final context = BudgetCityContextDto.fromJson(const {
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
    'censo_agregado': {'bercario1ano': 146.0},
  });

  testWidgets('exibe o censo escolar de um orçamento multi-cidade',
      (tester) async {
    await tester.pumpWidget(_host(
      numberOfCities: context.cityIds.length,
      citiesData: context.citiesData,
      censoAgregado: context.censoAgregado,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Censo Escolar'), findsOneWidget);
    expect(find.textContaining('3'), findsWidgets);
  });

  testWidgets('renderiza a partir dos índices quando não há censo agregado',
      (tester) async {
    await tester.pumpWidget(_host(
      numberOfCities: 1,
      citiesData: [context.citiesData.first],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Censo Escolar'), findsOneWidget);
  });
}
