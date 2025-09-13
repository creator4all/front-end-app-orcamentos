import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/widgets/widgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopBar(
        title: 'Perfil',
        showBackButton: true, // Exemplo de uso com botão de voltar
      ),
      body: SafeArea(
        child: Padding(
        padding: EdgeInsets.all(16.w),
        child: const Center(
          child: Text(
            'Perfil do Usuário\n(Em implementação)',
            textAlign: TextAlign.center,
          ),
        ),
        ),
      ),
    );
  }
}
