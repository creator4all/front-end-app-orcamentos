import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../../config/api_config.dart';
import '../stores/auth_store.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final AuthStore store = Modular.get<AuthStore>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo e Título lado a lado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo SVG
                      SvgPicture.asset(
                        'assets/images/logo-multimidia-simple.svg',
                        width: 50.w,
                        height: 50.h,
                        semanticsLabel: 'Logo Multimídia',
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 12.w),
                      // Título
                      Flexible(
                        child: Text(
                          'Multimídia: Parceiro (B2B)',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E88E5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 48.h),

                  // Campo de email
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'E-mail :',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Digite o email',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14.sp,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide:
                                const BorderSide(color: Color(0xFF1E88E5)),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, digite seu email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Por favor, digite um email válido';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Campo de senha
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Senha :',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Digite a senha',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14.sp,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide:
                                const BorderSide(color: Color(0xFF1E88E5)),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, digite sua senha';
                          }
                          if (value.length < 6) {
                            return 'A senha deve ter pelo menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Esqueci minha senha
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Navegar para tela de recuperação de senha
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Esqueci minha senha',
                        style: TextStyle(
                          color: const Color(0xFF1E88E5),
                          fontSize: 14.sp,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Botão de login
                  Observer(
                    builder: (_) => SizedBox(
                      width: double.infinity,
                      height: 39.h,
                      child: ElevatedButton(
                        onPressed: store.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                        child: store.isLoading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Acessar',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Botão de cadastro
                  SizedBox(
                    width: double.infinity,
                    height: 39.h,
                    child: OutlinedButton(
                      onPressed: () {
                        Modular.to.pushNamed('/auth/register/');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        side: BorderSide(
                          color: Colors.grey[400]!,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Cadastrar',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 48.h),

                  // Links de rodapé
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          // TODO: Navegar para política de privacidade
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Privacidade',
                          style: TextStyle(
                            color: const Color(0xFF1E88E5),
                            fontSize: 14.sp,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      SizedBox(width: 32.w),
                      TextButton(
                        onPressed: () {
                          // TODO: Navegar para wiki
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Wiki',
                          style: TextStyle(
                            color: const Color(0xFF1E88E5),
                            fontSize: 14.sp,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Exibir mensagem de erro, se houver
                  Observer(
                    builder: (_) => store.errorMessage != null &&
                            store.errorMessage!.isNotEmpty
                        ? Container(
                            margin: EdgeInsets.only(top: 16.h),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: Colors.red[200]!,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              store.errorMessage!,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 14.sp,
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

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Mostrar dialog de informação ANTES de tentar login
      _showLoginAttemptDialog();

      String? errorDetails;
      String? stackTraceDetails;

      try {
        await store.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        // Fechar dialog de tentativa
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Verificar se houve sucesso ou erro
        if (store.isLoggedIn) {
          // Login bem-sucedido
          if (mounted) {
            _showSuccessDialog();
          }
        } else if (store.errorMessage != null) {
          // Login falhou - capturar erro do store
          errorDetails = store.errorMessage!;
          if (mounted) {
            _showErrorDialog(errorDetails, null);
          }
        }
      } catch (e, stackTrace) {
        // Fechar dialog de tentativa
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Capturar qualquer exceção não tratada
        errorDetails = 'Exceção capturada: ${e.toString()}';
        stackTraceDetails = stackTrace.toString();
        if (mounted) {
          _showErrorDialog(errorDetails, stackTraceDetails);
        }
      }
    }
  }

  void _showLoginAttemptDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            SizedBox(
              width: 24.w,
              height: 24.h,
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
              ),
            ),
            SizedBox(width: 12.w),
            const Text('Tentando Login...'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conectando ao servidor:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: SelectableText(
                ApiConfig.baseUrl,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'monospace',
                  color: Colors.blue[900],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Email: ${_emailController.text.trim()}',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 4.h),
            Text(
              'Endpoint: ${ApiConfig.loginEndpoint}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 28.w),
            SizedBox(width: 12.w),
            const Text('Login Bem-Sucedido'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Você foi autenticado com sucesso!',
              style: TextStyle(fontSize: 16.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              'Email: ${_emailController.text.trim()}',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // O store já navegou automaticamente
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String errorMessage, String? stackTrace) {
    final fullError = StringBuffer();
    fullError.writeln('=== ERRO DE LOGIN ===');
    fullError.writeln('');
    fullError.writeln('URL Base: ${ApiConfig.baseUrl}');
    fullError.writeln('Endpoint: ${ApiConfig.loginEndpoint}');
    fullError.writeln('');
    fullError.writeln('Mensagem:');
    fullError.writeln(errorMessage);
    fullError.writeln('');
    fullError.writeln('Email tentado: ${_emailController.text.trim()}');
    fullError.writeln('Timestamp: ${DateTime.now().toIso8601String()}');

    if (stackTrace != null) {
      fullError.writeln('');
      fullError.writeln('=== STACK TRACE ===');
      fullError.writeln(stackTrace);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red[600], size: 28.w),
            SizedBox(width: 12.w),
            const Text('Erro no Login'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ocorreu um erro ao tentar fazer login:',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: SelectableText(
                  fullError.toString(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: 'monospace',
                    color: Colors.red[900],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: fullError.toString()));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      const Text('Erro copiado para a área de transferência'),
                  backgroundColor: Colors.green[600],
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.copy, size: 18),
                SizedBox(width: 4.w),
                const Text('Copiar Erro'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
            ),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
