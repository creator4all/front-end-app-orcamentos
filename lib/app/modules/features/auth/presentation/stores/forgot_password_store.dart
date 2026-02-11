import 'dart:async';

import 'package:mobx/mobx.dart';

import '../../domain/usecases/request_password_reset_usecase.dart';
import '../../domain/usecases/resend_otp_code_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/verify_otp_code_usecase.dart';

part 'forgot_password_store.g.dart';

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

  Timer? _resendTimer;

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

  @computed
  bool get canResendOtp => resendCountdown == 0;

  @computed
  bool get isPasswordValid => ResetPasswordUsecase.isPasswordValid(newPassword);

  @computed
  bool get passwordsMatch =>
      newPassword.isNotEmpty && newPassword == confirmPassword;

  @computed
  bool get hasMinLength => ResetPasswordUsecase.hasMinLength(newPassword);

  @computed
  bool get hasUppercase => ResetPasswordUsecase.hasUppercase(newPassword);

  @computed
  bool get hasSpecialChar => ResetPasswordUsecase.hasSpecialChar(newPassword);

  @computed
  bool get canSubmitNewPassword =>
      isPasswordValid && passwordsMatch && !isLoading;

  @action
  void setEmail(String value) {
    email = value;
    errorMessage = null;
  }

  @action
  void setOtpCode(String value) {
    otpCode = value;
    errorMessage = null;
  }

  @action
  void setNewPassword(String value) {
    newPassword = value;
    errorMessage = null;
  }

  @action
  void setConfirmPassword(String value) {
    confirmPassword = value;
    errorMessage = null;
  }

  @action
  void clearError() {
    errorMessage = null;
  }

  @action
  Future<bool> requestPasswordReset() async {
    isLoading = true;
    errorMessage = null;

    final result = await _requestPasswordResetUsecase.call(email: email);

    isLoading = false;

    return result.fold(
      (failure) {
        errorMessage = failure.message;
        return false;
      },
      (_) {
        startResendTimer();
        return true;
      },
    );
  }

  @action
  Future<bool> resendOtpCode() async {
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
        return false;
      },
      (_) {
        startResendTimer();
        return true;
      },
    );
  }

  @action
  Future<bool> verifyOtpCode() async {
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
        return false;
      },
      (isValid) {
        if (isValid) {
          return true;
        } else {
          errorMessage = 'Código inválido';
          return false;
        }
      },
    );
  }

  @action
  Future<bool> resetPassword() async {
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
        return false;
      },
      (_) {
        return true;
      },
    );
  }

  // Regra de negócio: intervalo de 60s entre reenvios de OTP
  @action
  void startResendTimer() {
    _resendTimer?.cancel();
    resendCountdown = 60;

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown > 0) {
        resendCountdown--;
      } else {
        timer.cancel();
      }
    });
  }

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

  void dispose() {
    _resendTimer?.cancel();
  }
}
