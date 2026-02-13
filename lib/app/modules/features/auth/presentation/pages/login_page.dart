import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multimidiaapp/app/shared/utils/email_validator.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_info_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

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
                  _buildHeader(),
                  SizedBox(height: 48.h),
                  _buildEmailField(),
                  SizedBox(height: 24.h),
                  _buildPasswordField(),
                  SizedBox(height: 12.h),
                  _buildForgotPasswordLink(),
                  SizedBox(height: 32.h),
                  _buildLoginButton(),
                  SizedBox(height: 16.h),
                  _buildRegisterButton(),
                  SizedBox(height: 48.h),
                  _buildFooterLinks(),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/images/logo-multimidia-simple.svg',
          width: 50.w,
          height: 50.h,
          semanticsLabel: 'Logo Multimídia',
          fit: BoxFit.contain,
        ),
        SizedBox(width: 12.w),
        Flexible(
          child: Text(
            'Multimídia B2B',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E88E5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('E-mail :'),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(hintText: 'Digite o email'),
          validator: EmailValidator.getError,
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Senha :'),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: _inputDecoration(
            hintText: 'Digite a senha',
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () {
          Modular.to.pushNamed('/auth/forgot-password');
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text('Esqueci minha senha', style: _linkTextStyle),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Observer(
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
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
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
    );
  }

  Widget _buildFooterLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () async {
            final Uri url = Uri.parse('https://politicas.creator4all.com/');
            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
              if (mounted) {
                CustomInfoDialog.show(
                  context: context,
                  type: DialogType.error,
                  title: 'Erro ao abrir link',
                  message: 'Não foi possível abrir a página de privacidade.',
                );
              }
            }
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text('Privacidade', style: _linkTextStyle),
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
          child: Text('Wiki', style: _linkTextStyle),
        ),
      ],
    );
  }

  TextStyle get _linkTextStyle => TextStyle(
        color: const Color(0xFF1E88E5),
        fontSize: 14.sp,
        decoration: TextDecoration.underline,
      );

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
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
        borderSide: const BorderSide(color: Color(0xFF1E88E5)),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      suffixIcon: suffixIcon,
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await store.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (!store.isLoggedIn && mounted) {
          _showLoginErrorDialog();
        }
      } catch (e) {
        if (mounted) {
          _showLoginErrorDialog();
        }
      }
    }
  }

  void _showLoginErrorDialog() {
    CustomInfoDialog.show(
      context: context,
      type: DialogType.error,
      title: 'Erro ao fazer login',
      message: 'Login ou senha incorretos, tente novamente!',
    );
  }
}
