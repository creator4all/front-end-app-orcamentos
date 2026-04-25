import 'package:flutter_modular/flutter_modular.dart';

import '../registration/registration_module.dart';
import 'presentation/pages/forgot_password_email_page.dart';
import 'presentation/pages/forgot_password_new_password_page.dart';
import 'presentation/pages/forgot_password_otp_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/splash_page.dart';

/// Módulo de autenticação seguindo Clean Architecture
///
/// NOTA: Todas as dependências (DataSources, Repositories, UseCases, Store)
/// estão registradas no AppModule para serem compartilhadas globalmente.
/// Este módulo contém apenas as rotas específicas de autenticação.
class AuthModule extends Module {
  @override
  List<Bind> get binds => [];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          '/splash',
          child: (context, args) => const SplashPage(),
        ),
        ChildRoute(
          '/login',
          child: (context, args) => const LoginPage(),
        ),
        ChildRoute(
          '/forgot-password',
          child: (context, args) => const ForgotPasswordEmailPage(),
        ),
        ChildRoute(
          '/forgot-password/otp',
          child: (context, args) => const ForgotPasswordOtpPage(),
        ),
        ChildRoute(
          '/forgot-password/new-password',
          child: (context, args) => const ForgotPasswordNewPasswordPage(),
        ),
        ModuleRoute('/register', module: RegistrationModule()),
        RedirectRoute('/', to: '/login'),
      ];
}
