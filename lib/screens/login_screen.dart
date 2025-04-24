import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../stores/auth_store.dart';
import '../stores/login_store.dart';
import '../theme/app_theme.dart';
import '../widgets/index.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  
  // MobX stores
  late final AuthStore _authStore;
  late final LoginStore _loginStore;
  
  @override
  void initState() {
    super.initState();
    // Get stores from StoreProvider
    final storeProvider = StoreProvider.of(context);
    _authStore = storeProvider.authStore;
    _loginStore = storeProvider.loginStore;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await _loginStore.login(
        _emailController.text,
        _passwordController.text,
      );

      if (success && mounted) {
        // Navigate to home screen or dashboard
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo verde
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      // Logo azul
                      Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.only(left: 4, top: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Título
                  const Text(
                    'Multimídia: Parceiro (B2B)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Campo de email
                  CustomTextField(
                    controller: _emailController,
                    label: 'E-mail:',
                    hintText: 'Digite o email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, digite seu email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Campo de senha
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Senha:',
                    hintText: 'Digite a senha',
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, digite sua senha';
                      }
                      return null;
                    },
                  ),
                  
                  // Esqueci minha senha
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButtonLink(
                      text: 'Esqueci minha senha',
                      onPressed: () {
                        // Navegar para tela de recuperação de senha
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Botão de login
                  Observer(
                    builder: (_) => PrimaryButton(
                      text: 'Acessar',
                      isLoading: _loginStore.isLoading,
                      onPressed: _login,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Botão de cadastro
                  SecondaryButton(
                    text: 'Cadastrar',
                    onPressed: () {
                      // Navegar para tela de cadastro
                      Navigator.pushNamed(context, '/cnpj-search');
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Links de rodapé
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButtonLink(
                        text: 'Privacidade',
                        onPressed: () {
                          // Navegar para política de privacidade
                        },
                      ),
                      const SizedBox(width: 20),
                      TextButtonLink(
                        text: 'Wiki',
                        onPressed: () {
                          // Navegar para wiki
                        },
                      ),
                    ],
                  ),
                  
                  // Exibir mensagem de erro, se houver
                  Observer(
                    builder: (_) => _loginStore.error != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            _loginStore.error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
