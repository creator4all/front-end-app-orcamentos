import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/widgets/searchable_dropdown_widget.dart';

/// Dropdown para selecionar qual cidade visualizar no censo multi-cidades
/// Usa SearchableDropdownWidget para permitir busca
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

    // Ordenar cidades alfabeticamente
    final sortedCities = List<Map<String, dynamic>>.from(cities)
      ..sort((a, b) => (a['nome'] as String).compareTo(b['nome'] as String));

    // Criar lista de itens: agregado + cidades ordenadas
    final List<String> items = [
      aggregateText,
      ...sortedCities.map((city) => '${city['nome']} - ${city['uf']}'),
    ];

    // Determinar valor selecionado
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
            false, // Manter ordem: agregado primeiro, depois cidades ordenadas
        onChanged: (value) {
          if (value == null) return;

          if (value == aggregateText) {
            onCitySelected(null);
          } else {
            // Encontrar cidade pelo nome
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
