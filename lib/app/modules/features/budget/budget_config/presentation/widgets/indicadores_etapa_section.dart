import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/indicador_etapa_entity.dart';

/// Widget que exibe os indicadores de etapa de um produto
/// Agrupados por Título do Grupo
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

    // Agrupa indicadores por nome do grupo manualmente
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
            // Título do Grupo
            if (grupoNome.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h, top: 8.h),
                child: Text(
                  grupoNome,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold, // Bold conforme imagem
                    color: Colors.black,
                  ),
                ),
              ),

            // Lista de Checkboxes do Grupo
            ...listaIndicadores
                .map((indicador) => _buildCheckboxItem(indicador)),

            SizedBox(height: 8.h), // Espaço entre grupos
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
          // Checkbox Customizado
          SizedBox(
            width: 20.w,
            height: 20.h,
            child: Checkbox(
              value: indicador.selecionado,
              onChanged: (value) {
                if (onToggle != null && value != null) {
                  onToggle!(indicador.produtoIndicadorId, value);
                }
              },
              activeColor: const Color(0xFF2830F2), // Azul quando selecionado
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r), // Leve arredondamento
              ),
              side: const BorderSide(
                color:
                    Color(0xFF8C8C8C), // Cinza na borda quando não selecionado
                width: 1.5,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              indicador.indicadorNome, // Usando indicadorNome (ex: 1º Ano)
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
