import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget de avatar do usuário que exibe:
/// - Imagem base64 se disponível
/// - Iniciais do nome com cor de fundo se não houver imagem
class UserAvatarWidget extends StatelessWidget {
  final String? avatarBase64;
  final String userName;
  final double radius;

  const UserAvatarWidget({
    super.key,
    this.avatarBase64,
    required this.userName,
    this.radius = 30,
  });

  /// Extrai as iniciais do nome
  /// "Pedro Penha" -> "PP"
  /// "Pedro" -> "P"
  /// "Pedro Penha Martins" -> "PM" (primeira e última)
  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }

    // Primeira e última inicial
    final first = parts.first[0].toUpperCase();
    final last = parts.last[0].toUpperCase();
    return '$first$last';
  }

  /// Gera uma cor consistente baseada no nome do usuário
  Color _getColorForName(String name) {
    // Lista de cores vibrantes para avatares
    const colors = [
      Color(0xFF1976D2), // Azul
      Color(0xFF388E3C), // Verde
      Color(0xFFD32F2F), // Vermelho
      Color(0xFF7B1FA2), // Roxo
      Color(0xFFF57C00), // Laranja
      Color(0xFF0097A7), // Cyan
      Color(0xFF5D4037), // Marrom
      Color(0xFF455A64), // Blue Grey
      Color(0xFFC2185B), // Rosa
      Color(0xFF512DA8), // Deep Purple
      Color(0xFF00796B), // Teal
      Color(0xFF689F38), // Light Green
    ];

    // Usar hash do nome para selecionar cor consistente
    final hash = name.hashCode.abs();
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    // Tentar decodificar imagem base64
    ImageProvider? imageProvider;
    if (avatarBase64 != null && avatarBase64!.isNotEmpty) {
      try {
        final base64Data = avatarBase64!.split(',').last;
        imageProvider = MemoryImage(base64Decode(base64Data));
      } catch (e) {}
    }

    // Se tem imagem, exibir
    if (imageProvider != null) {
      return CircleAvatar(
        radius: radius.r,
        backgroundColor: const Color(0xFFE0E0E0),
        backgroundImage: imageProvider,
      );
    }

    // Fallback: iniciais com cor
    final initials = _getInitials(userName);
    final backgroundColor = _getColorForName(userName);

    return CircleAvatar(
      radius: radius.r,
      backgroundColor: backgroundColor,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: (radius * 0.8).sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
