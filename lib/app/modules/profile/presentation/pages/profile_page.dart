import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: const Center(
          child: Text(
            'Perfil do Usuário\n(Em implementação)',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
