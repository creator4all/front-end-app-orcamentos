import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Tipos de dialog disponíveis
enum DialogType {
  /// Dialog informativo (azul)
  info,

  /// Dialog de sucesso (verde)
  success,

  /// Dialog de aviso (laranja)
  warning,

  /// Dialog de erro (vermelho)
  error,
}

/// Dialog customizado padronizado para mensagens informativas
///
/// Apresenta um ícone circular colorido, título, mensagem e botão de ação.
/// Segue o padrão visual estabelecido no app para consistência.
///
/// Exemplo de uso:
/// ```dart
/// CustomInfoDialog.show(
///   context: context,
///   type: DialogType.error,
///   title: 'Erro ao fazer login',
///   message: 'Login ou senha incorretos, tente novamente!',
/// );
/// ```
class CustomInfoDialog extends StatelessWidget {
  final DialogType type;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const CustomInfoDialog._({
    required this.type,
    required this.title,
    required this.message,
    required this.buttonText,
    this.onButtonPressed,
  });

  /// Exibe o dialog customizado
  ///
  /// [context] - Contexto do widget
  /// [type] - Tipo do dialog (info, success, warning, error)
  /// [title] - Título do dialog
  /// [message] - Mensagem descritiva
  /// [buttonText] - Texto do botão (padrão: "Entendi")
  /// [onButtonPressed] - Callback ao clicar no botão (padrão: fecha o dialog)
  /// [barrierDismissible] - Permitir fechar clicando fora (padrão: true)
  static Future<void> show({
    required BuildContext context,
    required DialogType type,
    required String title,
    required String message,
    String buttonText = 'Entendi',
    VoidCallback? onButtonPressed,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomInfoDialog._(
        type: type,
        title: title,
        message: message,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed,
      ),
    );
  }

  /// Cor de fundo do círculo do ícone baseada no tipo
  Color get _backgroundColor {
    switch (type) {
      case DialogType.info:
        return const Color(0xFFE3F2FD); // Azul claro
      case DialogType.success:
        return const Color(0xFFE8F5E9); // Verde claro
      case DialogType.warning:
        return const Color(0xFFFFF3E0); // Laranja claro
      case DialogType.error:
        return const Color(0xFFFFEBEE); // Vermelho claro
    }
  }

  /// Cor do ícone baseada no tipo
  Color get _iconColor {
    switch (type) {
      case DialogType.info:
        return const Color(0xFF117BBD); // Azul
      case DialogType.success:
        return const Color(0xFF56B34A); // Verde
      case DialogType.warning:
        return const Color(0xFFFF9800); // Laranja
      case DialogType.error:
        return const Color(0xFFF44336); // Vermelho
    }
  }

  /// Ícone baseado no tipo
  IconData get _icon {
    switch (type) {
      case DialogType.info:
        return Icons.info_outline;
      case DialogType.success:
        return Icons.check_circle;
      case DialogType.warning:
      case DialogType.error:
        return Icons.warning_rounded;
    }
  }

  /// Cor do botão baseada no tipo
  Color get _buttonColor {
    switch (type) {
      case DialogType.info:
        return const Color(0xFF117BBD); // Azul
      case DialogType.success:
        return const Color(0xFF56B34A); // Verde
      case DialogType.warning:
        return const Color(0xFFFF9800); // Laranja
      case DialogType.error:
        return const Color(0xFF1E88E5); // Azul (padrão do app)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone circular com fundo colorido
            Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                color: _backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon,
                color: _iconColor,
                size: 36.sp,
              ),
            ),
            SizedBox(height: 20.h),

            // Título
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            // Mensagem
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),

            // Botão de ação
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onButtonPressed?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
