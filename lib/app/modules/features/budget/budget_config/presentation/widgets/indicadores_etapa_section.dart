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
      children: grupos.entries.map((entry) {
        return _buildGrupoSection(entry.key, entry.value);
      }).toList(),
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
              fontWeight: FontWeight.bold,
              color: const Color(0xFF000000),
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
          // Checkbox customizado
          _buildCustomCheckbox(indicador.selecionado),
          SizedBox(width: 8.w),

          // Nome do indicador
          Expanded(
            child: Text(
              indicador.indicadorNome,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF000000),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói checkbox customizado com cantos arredondados
  Widget _buildCustomCheckbox(bool isChecked) {
    return Container(
      width: 17.w,
      height: 17.h,
      decoration: BoxDecoration(
        color: isChecked ? const Color(0xFF2830F2) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(
          color: const Color(0xFF484848),
          width: 1.5,
        ),
      ),
      child: isChecked
          ? Icon(
              Icons.check,
              color: const Color(0xFFFFFFFF),
              size: 12.sp,
            )
          : null,
    );
  }
}
