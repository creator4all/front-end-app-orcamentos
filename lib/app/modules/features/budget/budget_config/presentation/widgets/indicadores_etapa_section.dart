import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_checkbox.dart';

import '../../domain/entities/indicador_etapa_entity.dart';

class IndicadoresEtapaSection extends StatelessWidget {
  final List<IndicadorEtapaEntity> indicadores;
  final Function(int indicadorId, bool valor)? onToggle;

  const IndicadoresEtapaSection({
    super.key,
    required this.indicadores,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (indicadores.isEmpty) {
      return Container();
    }

    final grupos = <String, List<IndicadorEtapaEntity>>{};
    for (var indicador in indicadores) {
      if (!grupos.containsKey(indicador.grupoNome)) {
        grupos[indicador.grupoNome] = [];
      }
      grupos[indicador.grupoNome]!.add(indicador);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grupos.entries.map((entry) {
        final grupoNome = entry.key;
        final listaIndicadores = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (grupoNome.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h, top: 8.h),
                child: Text(
                  grupoNome,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ...listaIndicadores
                .map((indicador) => _buildCheckboxItem(indicador)),
            SizedBox(height: 8.h),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCheckboxItem(IndicadorEtapaEntity indicador) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          CustomCheckbox(
            value: indicador.selecionado,
            onChanged: onToggle == null
                ? null
                : (value) {
                    final toggleId = indicador.produtoIndicadorId > 0
                        ? indicador.produtoIndicadorId
                        : indicador.indicadorId;
                    onToggle!(toggleId, value);
                  },
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              indicador.indicadorNome,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF484848),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
