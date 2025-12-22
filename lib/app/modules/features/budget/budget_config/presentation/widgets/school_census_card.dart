import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../shared/widgets/card_layout.dart';

/// Card para exibir dados de Censo Escolar
/// Mostra: quantidade de turmas, municípios e total de estudantes
class SchoolCensusCard extends StatelessWidget {
  final int numberOfCities;
  final List<Map<String, dynamic>> citiesData;
  final VoidCallback? onTap;

  const SchoolCensusCard({
    super.key,
    required this.numberOfCities,
    required this.citiesData,
    this.onTap,
  });

  /// Calcula o total de turmas (quantidade de indices_etapa)
  int _calculateTotalClasses() {
    int totalClasses = 0;
    for (final city in citiesData) {
      // Dados vêm em 'cidades_has_indice_etapa' ao invés de 'indicadores'
      final indicadores = city['cidades_has_indice_etapa'] as List? ?? 
                          city['indicadores'] as List? ?? [];
      totalClasses += indicadores.length;
    }
    return totalClasses;
  }

  /// Calcula o total de estudantes (soma dos valores de indices_etapa)
  int _calculateTotalStudents() {
    int totalStudents = 0;
    for (final city in citiesData) {
      // Dados vêm em 'cidades_has_indice_etapa' ao invés de 'indicadores'
      final indicadores = city['cidades_has_indice_etapa'] as List? ?? 
                          city['indicadores'] as List? ?? [];
      for (final indicador in indicadores) {
        if (indicador is Map<String, dynamic>) {
          // Valor pode estar em 'pivot.etapa_valor' ou 'valor' ou 'etapa_valor'
          final pivot = indicador['pivot'] as Map<String, dynamic>?;
          final valor = pivot?['etapa_valor'] ?? 
                        indicador['etapa_valor'] ?? 
                        indicador['valor'] ?? 0;
          totalStudents +=
              (valor is int ? valor : (valor is double ? valor.toInt() : int.tryParse(valor.toString()) ?? 0));
        }
      }
    }
    return totalStudents;
  }

  /// Formata o texto de quantidade de turmas e municípios
  String _formatClassesAndCities(int classes, int cities) {
    if (cities > 1) {
      final classesText = '$classes Turmas';
      final citiesText = '$cities Municípios';
      return '$classesText\n$citiesText';
    } else {
      final classesText = '$classes Turmas';
      return classesText;
    }
  }

  /// Formata número com separadores
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    final totalClasses = _calculateTotalClasses();
    final totalStudents = _calculateTotalStudents();
    final classesAndCitiesText =
        _formatClassesAndCities(totalClasses, numberOfCities);

    // Envolver em GestureDetector para card inteiro ser clicável
    return GestureDetector(
      onTap: onTap,
      child: CardLayout(
        showCheckbox: false,
        icon: Icon(
          Icons.people,
          color: const Color(0xFF484848),
          size: 24.sp,
        ),
        secondColumn: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título
            Text(
              'Censo Escolar',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF484848),
              ),
            ),

            SizedBox(height: 2.h),

            // Turmas e Municípios
            Text(
              classesAndCitiesText,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF000000),
                height: 1.3,
              ),
            ),

            SizedBox(height: 2.h),

            // Total de Estudantes
            Text(
              '${_formatNumber(totalStudents)} Estudantes',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF000000),
              ),
            ),
          ],
        ),
        showBorder: false,
        showShadow: true,
        shadowColor: const Color(0xFF6A6F72),
        showActionButton: true,
        onActionTap: onTap,
      ),
    );
  }
}
