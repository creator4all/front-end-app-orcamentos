import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/censo_group_entity.dart';
import '../../domain/entities/censo_title_entity.dart';
import 'census_input_row_widget.dart';
import 'census_section_header_widget.dart';

class CensusDataSectionWidget<K> extends StatelessWidget {
  final CensoGroupEntity group;
  final bool isEditMode;
  final Map<K, TextEditingController> controllers;
  final ValueChanged<MapEntry<K, double?>>? onItemChanged;
  final K Function(CensoTitleEntity title) keySelector;

  const CensusDataSectionWidget({
    super.key,
    required this.group,
    required this.isEditMode,
    required this.controllers,
    required this.keySelector,
    this.onItemChanged,
  });

  static CensusDataSectionWidget<int> withId({
    Key? key,
    required CensoGroupEntity group,
    required bool isEditMode,
    required Map<int, TextEditingController> controllers,
    ValueChanged<MapEntry<int, double?>>? onItemChanged,
  }) {
    return CensusDataSectionWidget<int>(
      key: key,
      group: group,
      isEditMode: isEditMode,
      controllers: controllers,
      keySelector: (title) => title.id,
      onItemChanged: onItemChanged,
    );
  }

  static CensusDataSectionWidget<String> withNomeEtapa({
    Key? key,
    required CensoGroupEntity group,
    required bool isEditMode,
    required Map<String, TextEditingController> controllers,
    ValueChanged<MapEntry<String, double?>>? onItemChanged,
  }) {
    return CensusDataSectionWidget<String>(
      key: key,
      group: group,
      isEditMode: isEditMode,
      controllers: controllers,
      keySelector: (title) => title.nomeEtapa,
      onItemChanged: onItemChanged,
    );
  }

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
    final key = keySelector(title);

    final controller = controllers[key];

    final displayValue = controller != null
        ? (double.tryParse(controller.text) ?? title.valor)
        : title.valor;

    return CensusInputRowWidget(
      label: title.tituloExibicao,
      value: displayValue,
      isEditMode: isEditMode,
      controller: controller,
      onChanged: (value) {
        onItemChanged?.call(MapEntry(key, value));
      },
    );
  }
}
