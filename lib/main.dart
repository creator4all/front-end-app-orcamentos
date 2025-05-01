import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/budget_list_screen.dart';
import 'screens/cnpj_search_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'services/partner_service.dart';
import 'stores/auth_store.dart';
import 'stores/store_provider.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create stores
    final authStore = AuthStore();
    
    return MultiProvider(
      providers: [
        // Keep PartnerService with Provider for now
        ChangeNotifierProvider(create: (ctx) => PartnerService()),
      ],
      child: StoreProvider(
        child: MaterialApp(
          title: 'Multimídia Parceiro B2B',
          theme: AppTheme.lightTheme,
          home: authStore.isAuthenticated ? const BudgetListScreen() : const LoginScreen(),
          routes: {
            '/login': (ctx) => const LoginScreen(),
            '/budget_list': (ctx) => const BudgetListScreen(),
            '/cnpj-search': (ctx) => const CNPJSearchScreen(),
            '/profile': (ctx) => const ProfileScreen(),
          },
        ),
      ),
    );
  }
}
