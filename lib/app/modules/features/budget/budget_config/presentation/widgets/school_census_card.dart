import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/services/census_stage_rules.dart';
import 'package:multimidiaapp/app/shared/utils/quantity_utils.dart';

import '../../../../../../shared/widgets/card_layout.dart';
import '../../domain/services/census_value_normalizer.dart';

class SchoolCensusCard extends StatelessWidget {
  final int numberOfCities;
  final List<Map<String, dynamic>> citiesData;

  final Map<String, double>? censoAgregado;
  final VoidCallback? onTap;

  const SchoolCensusCard({
    super.key,
    required this.numberOfCities,
    required this.citiesData,
    this.censoAgregado,
    this.onTap,
  });

  List<dynamic> _extractIndicadores(Map<String, dynamic> city) {
    return city['indices'] as List? ??
        city['indicadores'] as List? ??
        city['cidades_has_indice_etapa'] as List? ??
        [];
  }

  double _parseValorIndicador(Map<String, dynamic> indicador) {
    final pivot = indicador['pivot'] as Map<String, dynamic>?;
    final valorRaw = indicador['valor'] ??
        pivot?['etapa_valor'] ??
        indicador['etapa_valor'] ??
        0;

    if (valorRaw is num) return valorRaw.toDouble();
    return double.tryParse(valorRaw.toString()) ?? 0.0;
  }

  int _calculateTotalClasses() {
    if (censoAgregado != null && censoAgregado!.isNotEmpty) {
      return censoAgregado!.values.where((v) => v > 0).length;
    }

    int totalClasses = 0;
    for (final city in citiesData) {
      final indicadores = _extractIndicadores(city);
      totalClasses += indicadores.length;
    }
    return totalClasses;
  }

  int _calculateTotalStudents() {
    if (censoAgregado != null && censoAgregado!.isNotEmpty) {
      return censoAgregado!.entries
          .where((e) => CensusStageRules.isStudentStage(e.key))
          .fold(
            0.0,
            (sum, e) =>
                sum +
                CensusValueNormalizer.consolidateStageValue(e.key, e.value),
          )
          .round();
    }

    int totalStudents = 0;
    for (final city in citiesData) {
      final indicadores = _extractIndicadores(city);
      for (final indicador in indicadores) {
        if (indicador is Map<String, dynamic>) {
          final nome =
              (indicador['nome_etapa'] ?? indicador['nome'] ?? '').toString();
          if (!CensusStageRules.isStudentStage(nome)) continue;
          totalStudents += CensusValueNormalizer.consolidateStageValue(
            nome,
            _parseValorIndicador(indicador),
          ).toInt();
        }
      }
    }
    return totalStudents;
  }

  String _pluralize(int count, String singular, String plural) {
    return count == 1 ? singular : plural;
  }

  @override
  Widget build(BuildContext context) {
    final totalClasses = _calculateTotalClasses();
    final totalStudents = _calculateTotalStudents();

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

  /// Variante de tres linhas do card.
  ///
  /// `CardLayout` limita a altura da linha em `70.h`, o que deixa cerca de
  /// `58.h` para esta coluna. Com tres linhas de 12.sp o respiro entre elas
  /// precisa ser menor que o da variante de cidade unica, que tem duas.
  Widget _buildMultiCityContent(int totalClasses, int totalStudents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Censo Escolar',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF828282),
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Text(
              '$totalClasses ${_pluralize(totalClasses, 'Turma', 'Turmas')}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF484848),
              ),
            ),
            SizedBox(width: 12.w),
            Flexible(
              child: Text(
                '$numberOfCities ${_pluralize(numberOfCities, 'Município selecionado', 'Municípios selecionados')}',
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
        SizedBox(height: 2.h),
        Text(
          '${QuantityUtils.format(totalStudents)} ${_pluralize(totalStudents, 'Estudante', 'Estudantes')}',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF484848),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleCityContent(int totalClasses, int totalStudents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Censo Escolar',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF484848),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          '$totalClasses ${_pluralize(totalClasses, 'Turma', 'Turmas')}',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF000000),
            height: 1.3,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          '${QuantityUtils.format(totalStudents)} ${_pluralize(totalStudents, 'Estudante', 'Estudantes')}',
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
