// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ForgotPasswordStore on _ForgotPasswordStoreBase, Store {
  Computed<bool>? _$canResendOtpComputed;

  @override
  bool get canResendOtp =>
      (_$canResendOtpComputed ??= Computed<bool>(() => super.canResendOtp,
              name: '_ForgotPasswordStoreBase.canResendOtp'))
          .value;
  Computed<bool>? _$isPasswordValidComputed;

  @override
  bool get isPasswordValid =>
      (_$isPasswordValidComputed ??= Computed<bool>(() => super.isPasswordValid,
              name: '_ForgotPasswordStoreBase.isPasswordValid'))
          .value;
  Computed<bool>? _$passwordsMatchComputed;

  @override
  bool get passwordsMatch =>
      (_$passwordsMatchComputed ??= Computed<bool>(() => super.passwordsMatch,
              name: '_ForgotPasswordStoreBase.passwordsMatch'))
          .value;
  Computed<bool>? _$hasMinLengthComputed;

  @override
  bool get hasMinLength =>
      (_$hasMinLengthComputed ??= Computed<bool>(() => super.hasMinLength,
              name: '_ForgotPasswordStoreBase.hasMinLength'))
          .value;
  Computed<bool>? _$hasUppercaseComputed;

  @override
  bool get hasUppercase =>
      (_$hasUppercaseComputed ??= Computed<bool>(() => super.hasUppercase,
              name: '_ForgotPasswordStoreBase.hasUppercase'))
          .value;
  Computed<bool>? _$hasSpecialCharComputed;

  @override
  bool get hasSpecialChar =>
      (_$hasSpecialCharComputed ??= Computed<bool>(() => super.hasSpecialChar,
              name: '_ForgotPasswordStoreBase.hasSpecialChar'))
          .value;
  Computed<bool>? _$canSubmitNewPasswordComputed;

  @override
  bool get canSubmitNewPassword => (_$canSubmitNewPasswordComputed ??=
          Computed<bool>(() => super.canSubmitNewPassword,
              name: '_ForgotPasswordStoreBase.canSubmitNewPassword'))
      .value;

  late final _$emailAtom =
      Atom(name: '_ForgotPasswordStoreBase.email', context: context);

  @override
  String get email {
    _$emailAtom.reportRead();
    return super.email;
  }

  @override
  set email(String value) {
    _$emailAtom.reportWrite(value, super.email, () {
      super.email = value;
    });
  }

  late final _$otpCodeAtom =
      Atom(name: '_ForgotPasswordStoreBase.otpCode', context: context);

  @override
  String get otpCode {
    _$otpCodeAtom.reportRead();
    return super.otpCode;
  }

  @override
  set otpCode(String value) {
    _$otpCodeAtom.reportWrite(value, super.otpCode, () {
      super.otpCode = value;
    });
  }

  late final _$newPasswordAtom =
      Atom(name: '_ForgotPasswordStoreBase.newPassword', context: context);

  @override
  String get newPassword {
    _$newPasswordAtom.reportRead();
    return super.newPassword;
  }

  @override
  set newPassword(String value) {
    _$newPasswordAtom.reportWrite(value, super.newPassword, () {
      super.newPassword = value;
    });
  }

  late final _$confirmPasswordAtom =
      Atom(name: '_ForgotPasswordStoreBase.confirmPassword', context: context);

  @override
  String get confirmPassword {
    _$confirmPasswordAtom.reportRead();
    return super.confirmPassword;
  }

  @override
  set confirmPassword(String value) {
    _$confirmPasswordAtom.reportWrite(value, super.confirmPassword, () {
      super.confirmPassword = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_ForgotPasswordStoreBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_ForgotPasswordStoreBase.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$resendCountdownAtom =
      Atom(name: '_ForgotPasswordStoreBase.resendCountdown', context: context);

  @override
  int get resendCountdown {
    _$resendCountdownAtom.reportRead();
    return super.resendCountdown;
  }

  @override
  set resendCountdown(int value) {
    _$resendCountdownAtom.reportWrite(value, super.resendCountdown, () {
      super.resendCountdown = value;
    });
  }

  late final _$requestPasswordResetAsyncAction = AsyncAction(
      '_ForgotPasswordStoreBase.requestPasswordReset',
      context: context);

  @override
  Future<bool> requestPasswordReset() {
    return _$requestPasswordResetAsyncAction
        .run(() => super.requestPasswordReset());
  }

  late final _$resendOtpCodeAsyncAction =
      AsyncAction('_ForgotPasswordStoreBase.resendOtpCode', context: context);

  @override
  Future<bool> resendOtpCode() {
    return _$resendOtpCodeAsyncAction.run(() => super.resendOtpCode());
  }

  late final _$verifyOtpCodeAsyncAction =
      AsyncAction('_ForgotPasswordStoreBase.verifyOtpCode', context: context);

  @override
  Future<bool> verifyOtpCode() {
    return _$verifyOtpCodeAsyncAction.run(() => super.verifyOtpCode());
  }

  late final _$resetPasswordAsyncAction =
      AsyncAction('_ForgotPasswordStoreBase.resetPassword', context: context);

  @override
  Future<bool> resetPassword() {
    return _$resetPasswordAsyncAction.run(() => super.resetPassword());
  }

  late final _$_ForgotPasswordStoreBaseActionController =
      ActionController(name: '_ForgotPasswordStoreBase', context: context);

  @override
  void setEmail(String value) {
    final _$actionInfo = _$_ForgotPasswordStoreBaseActionController.startAction(
        name: '_ForgotPasswordStoreBase.setEmail');
    try {
      return super.setEmail(value);
    } finally {
      _$_ForgotPasswordStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOtpCode(String value) {
    final _$actionInfo = _$_ForgotPasswordStoreBaseActionController.startAction(
        name: '_ForgotPasswordStoreBase.setOtpCode');
    try {
      return super.setOtpCode(value);
    } finally {
      _$_ForgotPasswordStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNewPassword(String value) {
    final _$actionInfo = _$_ForgotPasswordStoreBaseActionController.startAction(
        name: '_ForgotPasswordStoreBase.setNewPassword');
    try {
      return super.setNewPassword(value);
    } finally {
      _$_ForgotPasswordStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setConfirmPassword(String value) {
    final _$actionInfo = _$_ForgotPasswordStoreBaseActionController.startAction(
        name: '_ForgotPasswordStoreBase.setConfirmPassword');
    try {
      return super.setConfirmPassword(value);
    } finally {
      _$_ForgotPasswordStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearError() {
    final _$actionInfo = _$_ForgotPasswordStoreBaseActionController.startAction(
        name: '_ForgotPasswordStoreBase.clearError');
    try {
      return super.clearError();
    } finally {
      _$_ForgotPasswordStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void startResendTimer() {
    final _$actionInfo = _$_ForgotPasswordStoreBaseActionController.startAction(
        name: '_ForgotPasswordStoreBase.startResendTimer');
    try {
      return super.startResendTimer();
    } finally {
      _$_ForgotPasswordStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_ForgotPasswordStoreBaseActionController.startAction(
        name: '_ForgotPasswordStoreBase.reset');
    try {
      return super.reset();
    } finally {
      _$_ForgotPasswordStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
email: ${email},
otpCode: ${otpCode},
newPassword: ${newPassword},
confirmPassword: ${confirmPassword},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
resendCountdown: ${resendCountdown},
canResendOtp: ${canResendOtp},
isPasswordValid: ${isPasswordValid},
passwordsMatch: ${passwordsMatch},
hasMinLength: ${hasMinLength},
hasUppercase: ${hasUppercase},
hasSpecialChar: ${hasSpecialChar},
canSubmitNewPassword: ${canSubmitNewPassword}
    ''';
  }
}
