import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Dropdown para selecionar qual cidade visualizar no censo multi-cidades
class CitySelectorDropdown extends StatelessWidget {
  /// Lista de cidades disponíveis [{id, nome, uf}]
  final List<Map<String, dynamic>> cities;

  /// ID da cidade selecionada (null = agregado)
  final int? selectedCityId;

  /// Callback quando cidade é selecionada
  final ValueChanged<int?> onCitySelected;

  /// Texto para opção agregada
  final String aggregateText;

  const CitySelectorDropdown({
    super.key,
    required this.cities,
    required this.selectedCityId,
    required this.onCitySelected,
    this.aggregateText = 'Todas as cidades',
  });

  @override
  Widget build(BuildContext context) {
    if (cities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: selectedCityId,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: const Color(0xFF117BBD),
            size: 24.sp,
          ),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          items: [
            // Opção agregada
            DropdownMenuItem<int?>(
              value: null,
              child: Row(
                children: [
                  Icon(
                    Icons.layers,
                    size: 18.sp,
                    color: const Color(0xFF117BBD),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    aggregateText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: selectedCityId == null
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: selectedCityId == null
                          ? const Color(0xFF117BBD)
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            // Cidades individuais
            ...cities.map((city) {
              final cityId = city['id'] as int;
              final isSelected = selectedCityId == cityId;
              return DropdownMenuItem<int?>(
                value: cityId,
                child: Row(
                  children: [
                    Icon(
                      Icons.location_city,
                      size: 18.sp,
                      color: isSelected
                          ? const Color(0xFF117BBD)
                          : Colors.grey[600],
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        '${city['nome']} - ${city['uf']}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? const Color(0xFF117BBD)
                              : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: (value) {
            // Ignorar clique no separador
            onCitySelected(value);
          },
        ),
      ),
    );
  }
}
