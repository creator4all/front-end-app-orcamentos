import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../stores/auth_store.dart';
import '../../stores/store_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/index.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controller for confirmation text field
  final _confirmController = TextEditingController();
  
  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  // Confirmation dialog for account deletion
  void _showDeleteAccountDialog(BuildContext context, AuthStore authStore) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esta ação não pode ser desfeita. Digite "confirmar" para excluir sua conta.',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _confirmController,
              label: 'Confirmação:',
              hintText: 'Digite "confirmar"',
              keyboardType: TextInputType.text,
            ),
            Observer(
              builder: (_) => authStore.error != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      authStore.error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            ),
          ],
        ),
        actions: [
          TextButtonLink(
            text: 'Cancelar',
            onPressed: () {
              _confirmController.clear();
              Navigator.of(ctx).pop();
            },
          ),
          Observer(
            builder: (_) => PrimaryButton(
              text: 'Excluir',
              isLoading: authStore.isLoading,
              onPressed: () async {
                final success = await authStore.deleteAccount(_confirmController.text);
                if (success && mounted) {
                  _confirmController.clear();
                  Navigator.of(ctx).pop();
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              width: 100,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authStore = StoreProvider.of(context).authStore;
    
    return Observer(
      builder: (_) {
        final user = authStore.user;
        
        // Check if user is authenticated
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Text('Usuário não autenticado'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Perfil'),
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false, // Disable back button
            // X in the top right corner to close
            actions: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // User avatar
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // User name
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // CNPJ from user data if available
                  Text(
                    user.id.isNotEmpty ? user.id : '24.915.891/0001-74',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Edit Profile button (available to all)
                  _buildProfileButton(
                    icon: Icons.person,
                    text: 'Editar Perfil',
                    onPressed: () {
                      // Navigate to profile edit screen
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Management button (only for manager and admin)
                  if (authStore.isManager || authStore.isAdmin)
                    _buildProfileButton(
                      icon: Icons.settings,
                      text: 'Gestão',
                      onPressed: () {
                        // Navigate to management screen
                      },
                    ),
                  if (authStore.isManager || authStore.isAdmin)
                    const SizedBox(height: 16),
                  
                  // Wiki button (available to all)
                  _buildProfileButton(
                    icon: Icons.menu_book,
                    text: 'Wiki',
                    onPressed: () {
                      // Navigate to wiki screen
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Drive button (available to all)
                  _buildProfileButton(
                    icon: Icons.cloud,
                    text: 'Drive',
                    onPressed: () {
                      // Navigate to drive screen
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Product editing button (only for admin)
                  if (authStore.isAdmin)
                    _buildProfileButton(
                      icon: Icons.edit,
                      text: 'Edição de produtos',
                      onPressed: () {
                        // Navigate to product editing screen
                      },
                    ),
                  if (authStore.isAdmin)
                    const SizedBox(height: 16),
                  
                  // Logout button (available to all)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 16),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'Sair',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        await authStore.logout();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  
                  // Delete account button (available to all)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 16),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      label: const Text(
                        'Deletar conta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      onPressed: () {
                        _showDeleteAccountDialog(context, authStore);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
  
  // Method to build profile buttons
  Widget _buildProfileButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(icon, color: Colors.black),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
