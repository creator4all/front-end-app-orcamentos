import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../stores/auth_store.dart';
import '../stores/store_provider.dart';
import '../widgets/index.dart';
import 'budget_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authStore = StoreProvider.of(context).authStore;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Orçamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authStore.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Observer(
              builder: (_) => Text(
                'Bem-vindo, ${authStore.user?.name ?? "Usuário"}!',
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Esta é a tela inicial do aplicativo de gerenciamento de orçamentos.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              text: 'Ver Orçamentos',
              width: 200,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BudgetListScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
