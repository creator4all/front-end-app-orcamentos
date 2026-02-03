import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/utils/string_utils.dart';
import 'package:multimidiaapp/app/shared/widgets/searchable_dropdown_widget.dart';

class CitySelectorDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> cities;

  final int? selectedCityId;

  final ValueChanged<int?> onCitySelected;

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

    // Ordenar cidades alfabeticamente
    final sortedCities = List<Map<String, dynamic>>.from(cities)
      ..sort((a, b) =>
          compareIgnoringAccents(a['nome'] as String, b['nome'] as String));

    final List<String> items = [
      aggregateText,
      ...sortedCities.map((city) => '${city['nome']} - ${city['uf']}'),
    ];

    String? selectedValue;
    if (selectedCityId == null) {
      selectedValue = aggregateText;
    } else {
      final selectedCity = sortedCities.firstWhere(
        (c) => c['id'] == selectedCityId,
        orElse: () => <String, dynamic>{},
      );
      if (selectedCity.isNotEmpty) {
        selectedValue = '${selectedCity['nome']} - ${selectedCity['uf']}';
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SearchableDropdownWidget(
        label: '',
        hint: 'Selecione uma cidade',
        searchHint: 'Pesquisar cidade...',
        items: items,
        value: selectedValue,
        sortItems:
            false,
        onChanged: (value) {
          if (value == null) return;

          if (value == aggregateText) {
            onCitySelected(null);
          } else {
            final cityName = value.split(' - ').first;
            final city = sortedCities.firstWhere(
              (c) => c['nome'] == cityName,
              orElse: () => <String, dynamic>{},
            );
            if (city.isNotEmpty) {
              onCitySelected(city['id'] as int);
            }
          }
        },
      ),
    );
  }
}
