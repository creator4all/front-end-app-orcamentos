import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/indicador_etapa_entity.dart';

/// Widget que exibe os indicadores de etapa de um produto
/// agrupados por grupo (ex: Etapas de Ensino, Público-alvo, etc.)
class IndicadoresEtapaSection extends StatelessWidget {
  final List<IndicadorEtapaEntity> indicadores;

  const IndicadoresEtapaSection({
    super.key,
    required this.indicadores,
  });

  /// Agrupa indicadores por nome do grupo
  Map<String, List<IndicadorEtapaEntity>> get _indicadoresPorGrupo {
    final Map<String, List<IndicadorEtapaEntity>> grupos = {};

    for (var indicador in indicadores) {
      if (!grupos.containsKey(indicador.grupoNome)) {
        grupos[indicador.grupoNome] = [];
      }
      grupos[indicador.grupoNome]!.add(indicador);
    }

    return grupos;
  }

  @override
  Widget build(BuildContext context) {
    if (indicadores.isEmpty) {
      return const SizedBox.shrink();
    }

    final grupos = _indicadoresPorGrupo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Indicadores de Etapa',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),

        // Container com fundo e borda
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: grupos.entries.map((entry) {
              return _buildGrupoSection(entry.key, entry.value);
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Constrói uma seção para cada grupo de indicadores
  Widget _buildGrupoSection(
      String grupoNome, List<IndicadorEtapaEntity> indicadores) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome do grupo
          Text(
            grupoNome,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF117BBD),
            ),
          ),
          SizedBox(height: 8.h),

          // Lista de indicadores do grupo
          ...indicadores.map((indicador) => _buildIndicadorItem(indicador)),
        ],
      ),
    );
  }

  /// Constrói um item de indicador (checkbox + nome)
  Widget _buildIndicadorItem(IndicadorEtapaEntity indicador) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          // Checkbox (desabilitado, apenas para visualização)
          IgnorePointer(
            child: Checkbox(
              value: indicador.selecionado,
              onChanged: null,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              activeColor: const Color(0xFF117BBD),
            ),
          ),
          SizedBox(width: 8.w),

          // Nome do indicador
          Expanded(
            child: Text(
              indicador.indicadorNome,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.black87,
              ),
            ),
          ),

          // Badge "Padrão" (se valorPadrao for true)
          if (indicador.valorPadrao == true) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFF117BBD).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'Padrão',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF117BBD),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
