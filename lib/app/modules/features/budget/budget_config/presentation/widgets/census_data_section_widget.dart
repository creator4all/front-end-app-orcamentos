import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/censo_group_entity.dart';
import '../../domain/entities/censo_title_entity.dart';
import 'census_input_row_widget.dart';
import 'census_section_header_widget.dart';

/// Widget que renderiza uma seção completa do censo escolar
/// Inclui o header com título sublinhado e lista de itens
class CensusDataSectionWidget extends StatelessWidget {
  final CensoGroupEntity group;
  final bool isEditMode;
  final Map<int, TextEditingController> controllers;
  final ValueChanged<MapEntry<int, double>>? onItemChanged;

  const CensusDataSectionWidget({
    super.key,
    required this.group,
    required this.isEditMode,
    required this.controllers,
    this.onItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (group.titulos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CensusSectionHeaderWidget(title: group.nome),
        ...group.titulos.map((title) => _buildItem(title)),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _buildItem(CensoTitleEntity title) {
    // Garantir que o controller existe
    if (!controllers.containsKey(title.id)) {
      controllers[title.id] = TextEditingController(
        text: title.valor.toStringAsFixed(0),
      );
    }

    return CensusInputRowWidget(
      label: title.tituloExibicao,
      value: title.valor,
      isEditMode: isEditMode,
      controller: controllers[title.id],
      onChanged: (value) {
        if (onItemChanged != null) {
          onItemChanged!(MapEntry(title.id, value));
        }
      },
    );
  }
}
