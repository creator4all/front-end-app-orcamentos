import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/widgets/custom_top_bar.dart';
import '../../../../shared/widgets/city_badge_widget.dart';
import '../../../../shared/widgets/city_selection_modal.dart';
import '../../../../modules/budget/presentation/pages/config_new_budget.dart';

class MultiCitySchoolCensusPage extends StatefulWidget {
  const MultiCitySchoolCensusPage({super.key});

  @override
  State<MultiCitySchoolCensusPage> createState() => _MultiCitySchoolCensusPageState();
}

class _MultiCitySchoolCensusPageState extends State<MultiCitySchoolCensusPage> {
  // Selected cities data
  List<Map<String, String>> _selectedCities = [
    {'city': 'São Paulo', 'state': 'SP'},
    {'city': 'Rio de Janeiro', 'state': 'RJ'},
  ];

  // Mock data for school census (same structure as original)
  final Map<String, dynamic> _censusData = {
    'groups': [
      {
        'name': 'Pré Escola',
        'items': [
          {'name': 'Berçário', 'value': ''},
          {'name': 'Infantil I', 'value': ''},
          {'name': 'Infantil II', 'value': ''},
        ]
      },
      {
        'name': 'Ensino Fundamental I',
        'items': [
          {'name': '1º Ano', 'value': ''},
          {'name': '2º Ano', 'value': ''},
          {'name': '3º Ano', 'value': ''},
          {'name': '4º Ano', 'value': ''},
          {'name': '5º Ano', 'value': ''},
        ]
      },
      {
        'name': 'Ensino Fundamental II',
        'items': [
          {'name': '6º Ano', 'value': ''},
          {'name': '7º Ano', 'value': ''},
          {'name': '8º Ano', 'value': ''},
          {'name': '9º Ano', 'value': ''},
        ]
      },
    ]
  };

  // Controllers for text fields
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers for all items
    for (var group in _censusData['groups']) {
      for (var item in group['items']) {
        final key = '${group['name']}_${item['name']}';
        _controllers[key] = TextEditingController(text: item['value']);
      }
    }
    // Set initial mock data based on selected cities
    _updateMockDataForCities();
  }

  void _updateMockDataForCities() {
    if (_selectedCities.isNotEmpty) {
      // Mock data based on number of selected cities
      final cityCount = _selectedCities.length;

      // Update controller values with mock data
      for (var group in _censusData['groups']) {
        for (var item in group['items']) {
          final key = '${group['name']}_${item['name']}';
          if (_controllers.containsKey(key)) {
            // Generate mock values based on item type and city count
            String mockValue = '';
            if (item['name'].toString().toLowerCase().contains('berçário')) {
              mockValue = (15 * cityCount).toString();
            } else if (item['name'].toString().toLowerCase().contains('infantil')) {
              mockValue = (20 * cityCount).toString();
            } else if (item['name'].toString().contains('ano')) {
              mockValue = (30 * cityCount).toString();
            }
            _controllers[key]!.text = mockValue;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showAddCitiesModal() {
    CitySelectionModal.show(
      context: context,
      initialSelectedCities: _selectedCities,
      onCitiesSelected: (selectedCities) {
        print('DEBUG: Cities selected from modal: $selectedCities');
        setState(() {
          _selectedCities = selectedCities;
          _updateMockDataForCities();
        });
      },
    );
  }

  Widget _buildSelectedCitiesBadges() {
    if (_selectedCities.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: _selectedCities.map((cityData) {
          return CityBadgeWidget(
            city: cityData['city']!,
            state: cityData['state']!,
            onRemove: () {
              setState(() {
                _selectedCities.remove(cityData);
              });
            },
            showIcon: false,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGroupSection(Map<String, dynamic> group) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          Text(
            group['name'],
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF117BBD),
            ),
          ),
          SizedBox(height: 12.h),
          ...group['items'].map<Widget>((item) {
            final key = '${group['name']}_${item['name']}';
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      item['name'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _controllers[key],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 6.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.r),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.r),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.r),
                          borderSide: const BorderSide(color: Color(0xFF117BBD)),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: SizedBox(
        width: double.infinity,
        height: 40.h,
        child: ElevatedButton.icon(
          onPressed: () {
            // TODO: Implement save logic

            // Navigate to config_new_budget.dart
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const ConfigNewBudgetPage(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF56B34A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          icon: Icon(
            Icons.save,
            size: 18.sp,
            color: Colors.white,
          ),
          label: Text(
            'Salvar',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(
        title: 'Censo Escolar',
        showBackButton: true,
        actionButton: GestureDetector(
          onTap: _showAddCitiesModal,
          child: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: const Color(0xFF117BBD),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF117BBD).withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.add,
              size: 20.sp,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSelectedCitiesBadges(),
                    // Subtitle
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'Preencha os dados do censo escolar para as cidades selecionadas',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF828282),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ..._censusData['groups'].map<Widget>((group) => _buildGroupSection(group)),
                  ],
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }
}
