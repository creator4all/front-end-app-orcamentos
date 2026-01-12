import 'dart:async';

import 'package:mobx/mobx.dart';

import '../../domain/usecases/request_password_reset_usecase.dart';
import '../../domain/usecases/resend_otp_code_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/verify_otp_code_usecase.dart';

part 'forgot_password_store.g.dart';

/// Store MobX para gerenciamento de estado do fluxo de recuperação de senha
class ForgotPasswordStore = _ForgotPasswordStoreBase with _$ForgotPasswordStore;

abstract class _ForgotPasswordStoreBase with Store {
  final RequestPasswordResetUsecase _requestPasswordResetUsecase;
  final ResendOtpCodeUsecase _resendOtpCodeUsecase;
  final VerifyOtpCodeUsecase _verifyOtpCodeUsecase;
  final ResetPasswordUsecase _resetPasswordUsecase;

  _ForgotPasswordStoreBase(
    this._requestPasswordResetUsecase,
    this._resendOtpCodeUsecase,
    this._verifyOtpCodeUsecase,
    this._resetPasswordUsecase,
  );

  // Timer para countdown de reenvio
  Timer? _resendTimer;

  // ===== Observables =====

  @observable
  String email = '';

  @observable
  String otpCode = '';

  @observable
  String newPassword = '';

  @observable
  String confirmPassword = '';

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  int resendCountdown = 0;

  // ===== Computed =====

  /// Verifica se pode reenviar OTP (countdown zerado)
  @computed
  bool get canResendOtp => resendCountdown == 0;

  /// Verifica se a senha atende aos requisitos
  @computed
  bool get isPasswordValid => ResetPasswordUsecase.isPasswordValid(newPassword);

  /// Verifica se as senhas conferem
  @computed
  bool get passwordsMatch =>
      newPassword.isNotEmpty && newPassword == confirmPassword;

  /// Verifica requisito: mínimo 6 caracteres
  @computed
  bool get hasMinLength => ResetPasswordUsecase.hasMinLength(newPassword);

  /// Verifica requisito: pelo menos 1 letra maiúscula
  @computed
  bool get hasUppercase => ResetPasswordUsecase.hasUppercase(newPassword);

  /// Verifica requisito: pelo menos 1 caractere especial
  @computed
  bool get hasSpecialChar => ResetPasswordUsecase.hasSpecialChar(newPassword);

  /// Verifica se pode enviar nova senha (todos requisitos atendidos)
  @computed
  bool get canSubmitNewPassword =>
      isPasswordValid && passwordsMatch && !isLoading;

  // ===== Actions =====

  /// Atualiza o email
  @action
  void setEmail(String value) {
    email = value;
    errorMessage = null;
  }

  /// Atualiza o código OTP
  @action
  void setOtpCode(String value) {
    otpCode = value;
    errorMessage = null;
  }

  /// Atualiza a nova senha
  @action
  void setNewPassword(String value) {
    newPassword = value;
    errorMessage = null;
  }

  /// Atualiza a confirmação de senha
  @action
  void setConfirmPassword(String value) {
    confirmPassword = value;
    errorMessage = null;
  }

  /// Limpa a mensagem de erro
  @action
  void clearError() {
    errorMessage = null;
  }

  /// Solicita recuperação de senha (envia OTP para email)
  @action
  Future<bool> requestPasswordReset() async {
    print('🔑 ForgotPasswordStore.requestPasswordReset()');
    isLoading = true;
    errorMessage = null;

    final result = await _requestPasswordResetUsecase.call(email: email);

    isLoading = false;

    return result.fold(
      (failure) {
        errorMessage = failure.message;
        print('❌ Erro: ${failure.message}');
        return false;
      },
      (_) {
        print('✅ Email enviado com sucesso');
        startResendTimer();
        return true;
      },
    );
  }

  /// Reenvia código OTP
  @action
  Future<bool> resendOtpCode() async {
    print('🔄 ForgotPasswordStore.resendOtpCode()');

    if (!canResendOtp) {
      errorMessage = 'Aguarde $resendCountdown segundos para reenviar';
      return false;
    }

    isLoading = true;
    errorMessage = null;

    final result = await _resendOtpCodeUsecase.call(email: email);

    isLoading = false;

    return result.fold(
      (failure) {
        errorMessage = failure.message;
        print('❌ Erro: ${failure.message}');
        return false;
      },
      (_) {
        print('✅ Código reenviado com sucesso');
        startResendTimer();
        return true;
      },
    );
  }

  /// Verifica código OTP
  @action
  Future<bool> verifyOtpCode() async {
    print('🔢 ForgotPasswordStore.verifyOtpCode()');
    isLoading = true;
    errorMessage = null;

    final result = await _verifyOtpCodeUsecase.call(
      email: email,
      otpCode: otpCode,
    );

    isLoading = false;

    return result.fold(
      (failure) {
        errorMessage = failure.message;
        print('❌ Erro: ${failure.message}');
        return false;
      },
      (isValid) {
        if (isValid) {
          print('✅ Código válido');
          return true;
        } else {
          errorMessage = 'Código inválido';
          return false;
        }
      },
    );
  }

  /// Redefine a senha
  @action
  Future<bool> resetPassword() async {
    print('🔑 ForgotPasswordStore.resetPassword()');
    isLoading = true;
    errorMessage = null;

    final result = await _resetPasswordUsecase.call(
      email: email,
      otpCode: otpCode,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    isLoading = false;

    return result.fold(
      (failure) {
        errorMessage = failure.message;
        print('❌ Erro: ${failure.message}');
        return false;
      },
      (_) {
        print('✅ Senha redefinida com sucesso');
        return true;
      },
    );
  }

  /// Inicia o timer de countdown para reenvio (60 segundos)
  @action
  void startResendTimer() {
    // Cancelar timer anterior se existir
    _resendTimer?.cancel();

    // Iniciar countdown de 60 segundos
    resendCountdown = 60;

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown > 0) {
        resendCountdown--;
      } else {
        timer.cancel();
      }
    });
  }

  /// Reseta o store para estado inicial
  @action
  void reset() {
    email = '';
    otpCode = '';
    newPassword = '';
    confirmPassword = '';
    isLoading = false;
    errorMessage = null;
    resendCountdown = 0;
    _resendTimer?.cancel();
  }

  /// Dispose do timer
  void dispose() {
    _resendTimer?.cancel();
  }
}
