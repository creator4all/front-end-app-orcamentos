import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../shared/widgets/card_layout.dart';

/// Card para exibir dados de Censo Escolar
/// Mostra: quantidade de turmas, municípios e total de estudantes
class SchoolCensusCard extends StatelessWidget {
  final int numberOfCities;
  final List<Map<String, dynamic>> citiesData;

  /// Censo agregado para orçamentos multi-cidade
  /// Usado para calcular turmas (count > 0) e estudantes (soma)
  final Map<String, double>? censoAgregado;
  final VoidCallback? onTap;

  const SchoolCensusCard({
    super.key,
    required this.numberOfCities,
    required this.citiesData,
    this.censoAgregado,
    this.onTap,
  });

  /// Calcula o total de turmas
  /// Para multi-cidade: conta quantos itens em censoAgregado têm valor > 0
  /// Para cidade única: conta indices_etapa
  int _calculateTotalClasses() {
    // Se temos censo agregado, usar ele
    if (censoAgregado != null && censoAgregado!.isNotEmpty) {
      return censoAgregado!.values.where((v) => v > 0).length;
    }

    // Fallback para formato antigo
    int totalClasses = 0;
    for (final city in citiesData) {
      final indicadores = city['cidades_has_indice_etapa'] as List? ??
          city['indicadores'] as List? ??
          city['indices'] as List? ??
          [];
      totalClasses += indicadores.length;
    }
    return totalClasses;
  }

  /// Calcula o total de estudantes
  /// Para multi-cidade: soma valores em censoAgregado (excluindo professores - sufixo P)
  /// Para cidade única: soma valores de indices_etapa (excluindo professores)
  int _calculateTotalStudents() {
    // Se temos censo agregado, usar ele (excluindo professores)
    if (censoAgregado != null && censoAgregado!.isNotEmpty) {
      return censoAgregado!.entries
          .where((e) => !e.key.endsWith('P')) // Exclui professores
          .fold(0.0, (sum, e) => sum + e.value)
          .round();
    }

    // Fallback para formato antigo
    int totalStudents = 0;
    for (final city in citiesData) {
      final indicadores = city['cidades_has_indice_etapa'] as List? ??
          city['indicadores'] as List? ??
          city['indices'] as List? ??
          [];
      for (final indicador in indicadores) {
        if (indicador is Map<String, dynamic>) {
          // Excluir professores (nome terminando com P)
          final nome = indicador['nome_etapa'] ?? indicador['nome'] ?? '';
          if (nome.toString().endsWith('P')) continue;

          final pivot = indicador['pivot'] as Map<String, dynamic>?;
          final valor = pivot?['etapa_valor'] ??
              indicador['etapa_valor'] ??
              indicador['valor'] ??
              0;
          totalStudents += (valor is int
              ? valor
              : (valor is double
                  ? valor.toInt()
                  : int.tryParse(valor.toString().split('.').first) ?? 0));
        }
      }
    }
    return totalStudents;
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
        secondColumn: numberOfCities > 1
            ? _buildMultiCityContent(totalClasses, totalStudents)
            : _buildSingleCityContent(totalClasses, totalStudents),
        showBorder: false,
        showShadow: true,
        shadowColor: const Color(0xFF6A6F72),
        showActionButton: true,
        onActionTap: onTap,
      ),
    );
  }

  /// Constrói o conteúdo para múltiplas cidades (Layout Horizontal)
  Widget _buildMultiCityContent(int totalClasses, int totalStudents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Título
        Text(
          'Censo Escolar',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF828282),
          ),
        ),

        SizedBox(height: 4.h),

        // Linha com Turmas e Municípios (mesma linha, bold)
        Row(
          children: [
            Text(
              '$totalClasses Turmas',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF484848),
              ),
            ),
            SizedBox(width: 12.w),
            Flexible(
              child: Text(
                '$numberOfCities Municípios selecionados',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF484848),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        SizedBox(height: 4.h),

        // Total de Estudantes
        Text(
          '${_formatNumber(totalStudents)} Estudantes',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF484848),
          ),
        ),
      ],
    );
  }

  /// Constrói o conteúdo para cidade única (Layout Vertical Padrão)
  Widget _buildSingleCityContent(int totalClasses, int totalStudents) {
    return Column(
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

        // Turmas
        Text(
          '$totalClasses Turmas',
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
    );
  }
}
