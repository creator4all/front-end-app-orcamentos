import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'city_badge_widget.dart';
import 'searchable_dropdown_widget.dart';

/// A reusable modal for selecting multiple cities from Brazilian states
/// Integrates with GeoStore for dynamic data from backend
class CitySelectionModal {
  static Future<List<Map<String, dynamic>>?> show({
    required BuildContext context,
    required dynamic geo, // GeoStore instance
    required List<Map<String, dynamic>> initialSelectedCities,
  }) {
    return showModalBottomSheet<List<Map<String, dynamic>>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CitySelectionContent(
        geo: geo,
        initialSelectedCities: initialSelectedCities,
      ),
    );
  }
}

class _CitySelectionContent extends StatefulWidget {
  final dynamic geo;
  final List<Map<String, dynamic>> initialSelectedCities;

  const _CitySelectionContent({
    required this.geo,
    required this.initialSelectedCities,
  });

  @override
  State<_CitySelectionContent> createState() => _CitySelectionContentState();
}

class _CitySelectionContentState extends State<_CitySelectionContent> {
  late List<Map<String, dynamic>> _tempSelectedCities;
  dynamic _selectedEstado;
  dynamic _selectedCidade;

  @override
  void initState() {
    super.initState();
    _tempSelectedCities = List.from(widget.initialSelectedCities);
  }

  void _addCity() {
    if (_selectedCidade == null || _selectedEstado == null) return;

    // Verificar se já está na lista
    final jaExiste =
        _tempSelectedCities.any((c) => c['id'] == _selectedCidade.id);

    if (!jaExiste) {
      setState(() {
        _tempSelectedCities.add({
          'id': _selectedCidade.id,
          'nome': _selectedCidade.nome,
          'uf': _selectedEstado.uf,
        });

        // Resetar seleções para permitir adicionar mais cidades
        _selectedCidade = null;
        widget.geo.selecionarCidade(null);
      });
    }
  }

  void _removeCity(int cidadeId) {
    setState(() {
      _tempSelectedCities.removeWhere((c) => c['id'] == cidadeId);
    });
  }

  void _confirmar() {
    Navigator.of(context).pop(_tempSelectedCities);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 20.h),
            width: 100.w,
            height: 10.h,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Center(
              child: Text(
                'Adicionar cidades',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: const Color(0xFF000000),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Content - Scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
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
                  Observer(
                    builder: (_) {
                      final List<String> estadosNomes = widget.geo.estados
                          .map((dynamic e) => e.nome as String)
                          .cast<String>()
                          .toList();

                      return SearchableDropdownWidget(
                        label: '',
                        hint: 'Selecione o estado',
                        searchHint: 'Pesquisar estado...',
                        items: estadosNomes,
                        value: _selectedEstado?.nome,
                        onChanged: (value) async {
                          if (value == null) return;

                          final matches =
                              widget.geo.estados.where((e) => e.nome == value);
                          final estado =
                              matches.isNotEmpty ? matches.first : null;

                          if (estado != null) {
                            setState(() {
                              _selectedEstado = estado;
                              _selectedCidade = null;
                            });
                            await widget.geo.selecionarEstado(estado);
                          }
                        },
                      );
                    },
                  ),
                  SizedBox(height: 20.h),

                  // Cidade label and selector (only if state is selected)
                  if (_selectedEstado != null) ...[
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
                    Observer(
                      builder: (_) {
                        if (widget.geo.isLoadingCidades) {
                          return Container(
                            width: double.infinity,
                            height: 35.h,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(color: const Color(0xFFE0E0E0)),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF117BBD),
                              ),
                            ),
                          );
                        }

                        final List<String> cidadesNomes = widget.geo.cidades
                            .map((dynamic c) => c.nome as String)
                            .cast<String>()
                            .toList();

                        return SearchableDropdownWidget(
                          label: '',
                          hint: 'Selecione a cidade',
                          searchHint: 'Pesquisar cidade...',
                          items: cidadesNomes,
                          value: _selectedCidade?.nome,
                          onChanged: (value) {
                            if (value == null) return;

                            final matches = widget.geo.cidades
                                .where((c) => c.nome == value);
                            final cidade =
                                matches.isNotEmpty ? matches.first : null;

                            if (cidade != null) {
                              setState(() {
                                _selectedCidade = cidade;
                              });
                              // Adicionar cidade automaticamente quando selecionada
                              _addCity();
                            }
                          },
                        );
                      },
                    ),
                    SizedBox(height: 20.h),
                  ],

                  // Selected cities badges
                  if (_tempSelectedCities.isNotEmpty) ...[
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
                      children: _tempSelectedCities.map((cityData) {
                        return CityBadgeWidget(
                          city: cityData['nome']!,
                          state: cityData['uf']!,
                          onRemove: () => _removeCity(cityData['id']),
                          showIcon: true,
                          // Custom colors as per specification
                          backgroundColor: const Color(0xFF00364D),
                          textColor: const Color(0xFFEBF9FF),
                          iconBackgroundColor: const Color(0xFFEBF9FF),
                          iconColor: const Color(0xFF00364D),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ],
              ),
            ),
          ),

          // Fixed bottom button
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton.icon(
                onPressed: _tempSelectedCities.isEmpty ? null : _confirmar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0028C1),
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: const Color(0xFFEBEDFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                icon: Icon(
                  Icons.add_circle,
                  size: 20.sp,
                  color: const Color(0xFFEBEDFF),
                ),
                label: Text(
                  'Adicionar',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFEBEDFF),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
