import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../shared/widgets/custom_info_dialog.dart';
import '../../../../../shared/widgets/custom_top_bar.dart';
import '../stores/forgot_password_store.dart';

/// Página para definir a nova senha
class ForgotPasswordNewPasswordPage extends StatefulWidget {
  const ForgotPasswordNewPasswordPage({super.key});

  @override
  State<ForgotPasswordNewPasswordPage> createState() =>
      _ForgotPasswordNewPasswordPageState();
}

class _ForgotPasswordNewPasswordPageState
    extends State<ForgotPasswordNewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final ForgotPasswordStore store = Modular.get<ForgotPasswordStore>();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomTopBar(
        title: 'Nova Senha',
        showBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16.h),
                Center(
                  child: Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF3E0),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.security,
                      size: 40.sp,
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Crie uma nova senha',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  'Sua nova senha deve atender aos requisitos abaixo.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                _buildPasswordField(
                  label: 'Nova Senha',
                  controller: _passwordController,
                  obscure: _obscurePassword,
                  onToggleObscure: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  onChanged: store.setNewPassword,
                ),
                SizedBox(height: 16.h),
                _buildPasswordRequirements(),
                SizedBox(height: 24.h),
                _buildPasswordField(
                  label: 'Confirmar Senha',
                  controller: _confirmPasswordController,
                  obscure: _obscureConfirmPassword,
                  onToggleObscure: () {
                    setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                  onChanged: store.setConfirmPassword,
                ),
                SizedBox(height: 8.h),
                Observer(
                  builder: (_) {
                    if (store.confirmPassword.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Row(
                      children: [
                        Icon(
                          store.passwordsMatch
                              ? Icons.check_circle
                              : Icons.cancel,
                          size: 16.sp,
                          color:
                              store.passwordsMatch ? Colors.green : Colors.red,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          store.passwordsMatch
                              ? 'As senhas conferem'
                              : 'As senhas não conferem',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: store.passwordsMatch
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 32.h),
                Observer(
                  builder: (_) => SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed:
                          store.canSubmitNewPassword ? _handleSubmit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: store.isLoading
                          ? SizedBox(
                              width: 24.w,
                              height: 24.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Redefinir Senha',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggleObscure,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Digite sua senha',
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 14.sp,
            ),
            prefixIcon: Icon(
              Icons.lock_outline,
              color: Colors.grey[500],
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: onToggleObscure,
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
              borderSide: const BorderSide(color: Color(0xFF1E88E5)),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requisitos da senha:',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12.h),
          Observer(
            builder: (_) => _buildRequirementItem(
              'Mínimo 6 caracteres',
              store.hasMinLength,
            ),
          ),
          SizedBox(height: 8.h),
          Observer(
            builder: (_) => _buildRequirementItem(
              'Pelo menos 1 letra maiúscula',
              store.hasUppercase,
            ),
          ),
          SizedBox(height: 8.h),
          Observer(
            builder: (_) => _buildRequirementItem(
              'Pelo menos 1 caractere especial',
              store.hasSpecialChar,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 18.sp,
          color: isMet ? Colors.green : Colors.grey[400],
        ),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            color: isMet ? Colors.green[700] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    final success = await store.resetPassword();

    if (success && mounted) {
      await CustomInfoDialog.show(
        context: context,
        type: DialogType.success,
        title: 'Senha Redefinida!',
        message:
            'Sua senha foi alterada com sucesso. Faça login com sua nova senha.',
        buttonText: 'Ir para Login',
        onButtonPressed: () {
          store.reset();
          Modular.to.navigate('/auth/login');
        },
      );
    } else if (!success && mounted) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.error,
        title: 'Erro',
        message: store.errorMessage ?? 'Não foi possível redefinir a senha.',
      );
    }
  }
}
