import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../shared/widgets/custom_info_dialog.dart';
import '../../../../../shared/widgets/custom_top_bar.dart';
import '../stores/forgot_password_store.dart';

/// Página para inserir o código OTP de 6 dígitos
class ForgotPasswordOtpPage extends StatefulWidget {
  const ForgotPasswordOtpPage({super.key});

  @override
  State<ForgotPasswordOtpPage> createState() => _ForgotPasswordOtpPageState();
}

class _ForgotPasswordOtpPageState extends State<ForgotPasswordOtpPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  final ForgotPasswordStore store = Modular.get<ForgotPasswordStore>();

  @override
  void initState() {
    super.initState();
    // Iniciar timer se ainda não foi iniciado
    if (store.resendCountdown == 0) {
      store.startResendTimer();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomTopBar(
        title: 'Verificar Código',
        showBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 32.h),

              // Ícone de código
              Center(
                child: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 40.sp,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Título
              Text(
                'Digite o código',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              // Descrição
              Observer(
                builder: (_) => Text(
                  'Enviamos um código de 6 dígitos para\n${store.email}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 32.h),

              // Campos de OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) => _buildOtpField(index)),
              ),
              SizedBox(height: 32.h),

              // Botão de verificar
              Observer(
                builder: (_) => SizedBox(
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: store.isLoading ? null : _handleVerify,
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
                            'Verificar',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Link de reenviar código
              Observer(
                builder: (_) => Center(
                  child: store.canResendOtp
                      ? TextButton(
                          onPressed: _handleResend,
                          child: Text(
                            'Reenviar código',
                            style: TextStyle(
                              color: const Color(0xFF1E88E5),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : Text(
                          'Reenviar código em ${store.resendCountdown}s',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14.sp,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 32.h),

              // Texto de ajuda
              Center(
                child: Text(
                  'Não recebeu o código? Verifique a caixa de spam.',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 45.w,
      height: 55.h,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: '',
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
            borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            // Mover para próximo campo
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            // Mover para campo anterior
            _focusNodes[index - 1].requestFocus();
          }

          // Atualizar código no store
          store.setOtpCode(_otpCode);
        },
      ),
    );
  }

  Future<void> _handleVerify() async {
    if (_otpCode.length != 6) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.warning,
        title: 'Código Incompleto',
        message: 'Por favor, digite o código de 6 dígitos.',
      );
      return;
    }

    store.setOtpCode(_otpCode);
    final success = await store.verifyOtpCode();

    if (success && mounted) {
      // Navegar para página de nova senha
      Modular.to.pushNamed('/auth/forgot-password/new-password');
    } else if (!success && mounted) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.error,
        title: 'Código Inválido',
        message: store.errorMessage ?? 'O código informado está incorreto.',
      );
      // Limpar campos
      for (final controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  Future<void> _handleResend() async {
    final success = await store.resendOtpCode();

    if (success && mounted) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.success,
        title: 'Código Reenviado',
        message: 'Um novo código foi enviado para seu e-mail.',
      );
    } else if (!success && mounted) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.error,
        title: 'Erro',
        message: store.errorMessage ?? 'Não foi possível reenviar o código.',
      );
    }
  }
}
