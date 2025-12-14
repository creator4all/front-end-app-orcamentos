import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/censo_escolar_entity.dart';

/// Card que exibe os dados do censo escolar organizados por grupos e títulos
class CensoSchoolCard extends StatelessWidget {
  final int numberOfCities;
  final List<Map<String, dynamic>> citiesData;
  final VoidCallback? onTap;
  final CensoEscolarEntity? censoEscolar;

  const CensoSchoolCard({
    super.key,
    required this.numberOfCities,
    required this.citiesData,
    this.onTap,
    this.censoEscolar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.bar_chart,
                    color: const Color(0xFF117BBD),
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Censo Escolar',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '$numberOfCities cidade${numberOfCities > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.edit,
                      color: const Color(0xFF117BBD),
                      size: 20.sp,
                    ),
                ],
              ),

              SizedBox(height: 16.h),

              // Dados do censo (versão simples original)
              if (citiesData.isNotEmpty) ...[
                _buildLegacyCensoData(citiesData.first),
              ] else ...[
                Text(
                  'Nenhum dado do censo disponível',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build legado para compatibilidade com dados antigos
  Widget _buildLegacyCensoData(Map<String, dynamic> cityData) {
    final indicadores = cityData['indicadores'] as List? ?? [];

    return Column(
      children: [
        ...indicadores.map((indicador) {
          final nome = indicador['nome'] as String;
          final valor = indicador['valor'] as int;

          return Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatarNomeIndicador(nome),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  valor.toString(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// Formata nome do indicador para exibição (legado)
  String _formatarNomeIndicador(String nome) {
    final Map<String, String> titulos = {
      'bercario': 'Berçário',
      'maternal': 'Maternal',
      'in4ano': 'Infantil - 4 anos',
      'in5ano': 'Infantil - 5 anos',
      'ef1ano': '1º Ano',
      'ef2ano': '2º Ano',
      'ef3ano': '3º Ano',
      'ef4ano': '4º Ano',
      'ef5ano': '5º Ano',
      'ef6ano': '6º Ano',
      'ef7ano': '7º Ano',
      'ef8ano': '8º Ano',
      'ef9ano': '9º Ano',
      'em1ano': '1º Ano - EM',
      'em2ano': '2º Ano - EM',
      'em3ano': '3º Ano - EM',
      'efEja': 'EJA - EF',
      'emEja': 'EJA - EM',
      'professores': 'Professores',
      'cursistas': 'Cursistas',
    };

    return titulos[nome] ?? nome;
  }
}
