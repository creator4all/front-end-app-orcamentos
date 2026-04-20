class AuthMessages {
  static const int otpExpirationMinutes = 5;

  static const String otpInvalidOrExpired =
      'Código inválido ou expirado. Solicite um novo código.';

  static const String otpResentSuccess =
      'Um novo código foi enviado para seu e-mail. Ele expira em 5 minutos.';

  static const String recoveryEmailHint =
      'Enviaremos um código de 6 dígitos válido por 5 minutos para o seu e-mail cadastrado.';

  static const String otpIncomplete =
      'Por favor, digite o código de 6 dígitos.';

  static String otpScreenHint(String email) {
    return 'Enviamos um código de 6 dígitos para\n$email.\nEle expira em $otpExpirationMinutes minutos.';
  }
}
