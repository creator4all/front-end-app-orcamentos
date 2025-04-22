import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cnpj_search_screen.dart';
import 'services/auth_service.dart';
import 'services/partner_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthService()),
        ChangeNotifierProvider(create: (ctx) => PartnerService()),
      ],
      child: Consumer<AuthService>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Multimídia Parceiro B2B',
          theme: AppTheme.lightTheme,
          home: auth.isAuthenticated ? const HomeScreen() : const LoginScreen(),
          routes: {
            '/login': (ctx) => const LoginScreen(),
            '/home': (ctx) => const HomeScreen(),
            '/cnpj-search': (ctx) => const CNPJSearchScreen(),
          },
        ),
      ),
    );
  }
}
