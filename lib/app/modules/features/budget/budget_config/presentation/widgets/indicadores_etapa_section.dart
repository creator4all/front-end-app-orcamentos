import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_checkbox.dart';

import '../../domain/entities/indicador_etapa_entity.dart';

class IndicadoresEtapaSection extends StatelessWidget {
  final List<IndicadorEtapaEntity> indicadores;
  final Function(int indicadorId, bool valor)? onToggle;

  /// Quando false, os indicadores ficam visíveis porém desabilitados (cinza).
  final bool enabled;

  /// Chamado ao tocar em qualquer indicador quando [enabled] é false.
  final VoidCallback? onBlockedTap;

  const IndicadoresEtapaSection({
    super.key,
    required this.indicadores,
    this.onToggle,
    this.enabled = true,
    this.onBlockedTap,
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
            _buildSelectAllItem(listaIndicadores),
            ...listaIndicadores
                .map((indicador) => _buildCheckboxItem(indicador)),
            SizedBox(height: 8.h),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSelectAllItem(
    List<IndicadorEtapaEntity> listaIndicadores,
  ) {
    final isGroupFullySelected =
        listaIndicadores.every((indicador) => indicador.selecionado);
    final label =
        isGroupFullySelected ? 'Deselecionar todos' : 'Selecionar todos';

    void toggleAll() {
      final targetValue = !isGroupFullySelected;
      for (final indicador in listaIndicadores) {
        if (indicador.selecionado != targetValue) {
          onToggle?.call(indicador.indicadorId, targetValue);
        }
      }
    }

    final row = Row(
      children: [
        CustomCheckbox(
          value: isGroupFullySelected,
          onChanged: (!enabled || onToggle == null) ? null : (_) => toggleAll(),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color:
                  enabled ? const Color(0xFF117BBD) : const Color(0xFFBFBFBF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: !enabled && onBlockedTap != null
          ? GestureDetector(onTap: onBlockedTap, child: row)
          : GestureDetector(onTap: enabled ? toggleAll : null, child: row),
    );
  }

  Widget _buildCheckboxItem(IndicadorEtapaEntity indicador) {
    final row = Row(
      children: [
        CustomCheckbox(
          value: indicador.selecionado,
          onChanged: (!enabled || onToggle == null)
              ? null
              : (value) {
                  onToggle!(indicador.indicadorId, value);
                },
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            indicador.indicadorNome,
            style: TextStyle(
              fontSize: 14.sp,
              color:
                  enabled ? const Color(0xFF484848) : const Color(0xFFBFBFBF),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: !enabled && onBlockedTap != null
          ? GestureDetector(onTap: onBlockedTap, child: row)
          : row,
    );
  }
}
