import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:multimidiaapp/app/shared/core/navigation/app_route_observer.dart';
import 'package:multimidiaapp/stores/store_provider.dart';

import 'app_module.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(
    ModularApp(
      module: AppModule(),
      child: Builder(
        builder: (context) => StoreProvider(
          child: const MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // `setObservers` notifica o routerDelegate; agendamos para depois do
    // primeiro frame para não disparar rebuild durante a construção da árvore.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Modular.setObservers([appRouteObserver]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Multimídia App - Orçamentos',
          theme: AppTheme.lightTheme,
          routeInformationParser: Modular.routeInformationParser,
          routerDelegate: Modular.routerDelegate,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('pt', 'BR'),
            Locale('en', 'US'),
          ],
          locale: const Locale('pt', 'BR'),
        );
      },
    );
  }
}
