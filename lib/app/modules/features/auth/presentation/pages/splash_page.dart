import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../stores/auth_store.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final authStore = Modular.get<AuthStore>();

    try {
      await authStore.loadCurrentUser();

      if (authStore.isLoggedIn && authStore.currentUser != null) {
        Modular.to.pushReplacementNamed('/budget/');
      } else {
        Modular.to.pushReplacementNamed('/auth/login');
      }
    } catch (_) {
      Modular.to.pushReplacementNamed('/auth/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/logo-multimidia-simple.svg',
              width: 80.w,
              height: 80.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: 24.w,
              height: 24.h,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF1E88E5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
