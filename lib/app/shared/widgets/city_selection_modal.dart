import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'city_badge_widget.dart';
import 'custom_modal.dart';

/// A reusable modal for selecting cities from Brazilian states
class CitySelectionModal {
  static Future<void> show({
    required BuildContext context,
    required List<Map<String, String>> initialSelectedCities,
    required Function(List<Map<String, String>>) onCitiesSelected,
  }) {
    return CustomModal.show(
      context: context,
      title: 'Adicionar cidades',
      content: _CitySelectionContent(
        initialSelectedCities: initialSelectedCities,
        onCitiesSelected: onCitiesSelected,
      ),
    );
  }
}

class _CitySelectionContent extends StatefulWidget {
  final List<Map<String, String>> initialSelectedCities;
  final Function(List<Map<String, String>>) onCitiesSelected;

  const _CitySelectionContent({
    required this.initialSelectedCities,
    required this.onCitiesSelected,
  });

  @override
  State<_CitySelectionContent> createState() => _CitySelectionContentState();
}

class _CitySelectionContentState extends State<_CitySelectionContent> {
  late List<Map<String, String>> _selectedCities;
  String? _selectedState;
  String? _selectedCity;

  final Map<String, List<String>> _citiesByState = {
    'São Paulo': ['São Paulo', 'Campinas', 'Santos', 'Ribeirão Preto', 'Sorocaba'],
    'Rio de Janeiro': ['Rio de Janeiro', 'Niterói', 'Campos dos Goytacazes', 'Nova Iguaçu'],
    'Minas Gerais': ['Belo Horizonte', 'Uberlândia', 'Contagem', 'Juiz de Fora'],
    'Bahia': ['Salvador', 'Feira de Santana', 'Vitória da Conquista'],
    'Paraná': ['Curitiba', 'Londrina', 'Maringá'],
    'Rio Grande do Sul': ['Porto Alegre', 'Caxias do Sul', 'Pelotas'],
    'Pernambuco': ['Recife', 'Olinda', 'Caruaru'],
    'Ceará': ['Fortaleza', 'Caucaia', 'Juazeiro do Norte'],
  };

  final List<String> _states = [];

  @override
  void initState() {
    super.initState();
    _selectedCities = List.from(widget.initialSelectedCities);
    _states.addAll(_citiesByState.keys);
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado label
            Text(
              'Estado',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF000000),
              ),
            ),
            SizedBox(height: 8.h),

            // Estado selector
            Container(
              width: double.infinity,
              height: 35.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedState,
                  hint: Text(
                    'Selecione o estado',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                  isExpanded: true,
                  items: _states.map((state) {
                    return DropdownMenuItem(
                      value: state,
                      child: Text(
                        state,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: const Color(0xFF000000),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setModalState(() {
                      _selectedState = value;
                      _selectedCity = null; // Reset city when state changes
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Cidade label
            if (_selectedState != null) ...[
              Text(
                'Cidade',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF000000),
                ),
              ),
              SizedBox(height: 8.h),

              // Cidade selector
              Container(
                width: double.infinity,
                height: 35.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCity,
                    hint: Text(
                      'Selecione a cidade',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                    isExpanded: true,
                    items: (_citiesByState[_selectedState!] ?? []).map((city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(
                          city,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: const Color(0xFF000000),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        _selectedCity = value;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],

            // Selected cities badges
            if (_selectedCities.isNotEmpty) ...[
              Text(
                'Cidades selecionadas',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF000000),
                ),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 8.h,
                children: _selectedCities.map((cityData) {
                  return CityBadgeWidget(
                    city: cityData['city']!,
                    state: cityData['state']!,
                    onRemove: () {
                      setModalState(() {
                        _selectedCities.remove(cityData);
                      });
                    },
                    showIcon: true,
                  );
                }).toList(),
              ),
              SizedBox(height: 20.h),
            ],

            // Add button
            Container(
              width: double.infinity,
              height: 40.h,
              child: ElevatedButton.icon(
                onPressed: _selectedCity != null && _selectedState != null
                    ? () {
                        final newCity = {'city': _selectedCity!, 'state': _selectedState!};
                        if (!_selectedCities.any((city) =>
                            city['city'] == _selectedCity && city['state'] == _selectedState)) {
                          setModalState(() {
                            _selectedCities.add(newCity);
                            _selectedCity = null;
                            _selectedState = null;
                          });
                        }
                        // Close modal and return data
                        Navigator.of(context).pop(_selectedCities);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF56B34A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  elevation: 0,
                ),
                icon: Icon(
                  Icons.add,
                  size: 20.sp,
                ),
                label: Text(
                  'Adicionar',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
