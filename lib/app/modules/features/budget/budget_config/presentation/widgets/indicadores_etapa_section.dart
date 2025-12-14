import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/indicador_etapa_entity.dart';

/// Widget que exibe os indicadores de etapa de um produto
class IndicadoresEtapaSection extends StatelessWidget {
  final List<IndicadorEtapaEntity> indicadores;

  const IndicadoresEtapaSection({
    super.key,
    required this.indicadores,
  });

  @override
  Widget build(BuildContext context) {
    if (indicadores.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFD9D9D9)),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          'Nenhum indicador disponível para este produto.',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD9D9D9)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da seção
          Text(
            'INDICADORES',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF000000),
            ),
          ),
          SizedBox(height: 12.h),

          // Lista de indicadores com checkboxes
          ...indicadores.map((indicador) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  // Checkbox customizado
                  SizedBox(
                    width: 17.w,
                    height: 17.h,
                    child: Checkbox(
                      value: indicador.selecionado,
                      onChanged: (value) {
                        // Implementar lógica de atualização se necessário
                      },
                      activeColor: const Color(0xFF2830F2),
                      checkColor: Colors.white,
                      fillColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return const Color(0xFF2830F2);
                          }
                          return Colors.white;
                        },
                      ),
                      side: BorderSide(
                        color: indicador.selecionado
                            ? const Color(0xFF2830F2)
                            : const Color(0xFFD9D9D9),
                        width: 1.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Nome do indicador
                  Expanded(
                    child: Text(
                      indicador.indicadorNome,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF000000),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
