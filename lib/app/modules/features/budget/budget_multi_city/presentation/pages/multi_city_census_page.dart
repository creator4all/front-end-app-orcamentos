import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/widgets/city_badge_widget.dart';
import 'package:multimidiaapp/app/shared/widgets/city_selection_modal.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_info_dialog.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_top_bar.dart';
import 'package:multimidiaapp/stores/store_provider.dart';

import '../../../budget_config/domain/entities/censo_group_entity.dart';
import '../../../budget_config/presentation/widgets/census_data_section_widget.dart';
import '../stores/multi_city_census_store.dart';
import '../widgets/city_selector_dropdown.dart';

class MultiCityCensusPage extends StatefulWidget {
  final String budgetName;

  final int? budgetId;

  final List<Map<String, dynamic>> selectedCities;

  const MultiCityCensusPage({
    super.key,
    required this.budgetName,
    this.budgetId,
    required this.selectedCities,
  });

  @override
  State<MultiCityCensusPage> createState() => _MultiCityCensusPageState();
}

class _MultiCityCensusPageState
    extends ModularState<MultiCityCensusPage, MultiCityCensusStore> {
  final Map<String, TextEditingController> _controllers = {};
  late dynamic _geoStore;

  @override
  void initState() {
    super.initState();
    store.setBudgetName(widget.budgetName);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.selectedCities.isNotEmpty) {
        store.setSelectedCities(widget.selectedCities);
        await store.loadCensusForCities();
        if (mounted) {
          _syncControllersWithStore();
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _geoStore = StoreProvider.of(context).geoStore;
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _showCitySelectionModal() async {
    if (_geoStore.estados.isEmpty && !_geoStore.isLoadingEstados) {
      await _geoStore.carregarEstados();
    }

    if (!mounted) return;

    final result = await CitySelectionModal.show(
      context: context,
      geo: _geoStore,
      initialSelectedCities: store.selectedCities.toList(),
    );

    if (result != null && result.isNotEmpty) {
      store.setSelectedCities(result);
      await store.loadCensusForCities();
      _syncControllersWithStore();
    }
  }

  void _syncControllersWithStore() {
    final census = store.currentCensus;
    if (census == null) return;

    final displayValues = store.displayValues;

    for (var group in census.grupos) {
      for (var title in group.titulos) {
        final value = displayValues[title.nomeEtapa] ?? title.valor;
        final newValue = value.toStringAsFixed(0);
        if (_controllers.containsKey(title.nomeEtapa)) {
          if (_controllers[title.nomeEtapa]!.text != newValue) {
            _controllers[title.nomeEtapa]!.text = newValue;
          }
        } else {
          _controllers[title.nomeEtapa] = TextEditingController(text: newValue);
        }
      }
    }
  }

  void _onValueChanged(int cityId, String nomeEtapa, double value) {
    store.updateValue(cityId, nomeEtapa, value);
  }

  Future<void> _handleNext() async {
    if (!store.hasCities) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.warning,
        title: 'Nenhuma cidade selecionada',
        message: 'Selecione ao menos uma cidade para continuar.',
      );
      return;
    }

    final budgetData = await store.createBudget();

    if (budgetData != null) {
      final rawBudgetId = budgetData['id'];
      final budgetId = switch (rawBudgetId) {
        int value => value,
        String value => int.tryParse(value),
        _ => int.tryParse(rawBudgetId?.toString() ?? ''),
      };

      if (budgetId == null || budgetId <= 0) {
        if (mounted) {
          CustomInfoDialog.show(
            context: context,
            type: DialogType.error,
            title: 'Erro ao criar orçamento',
            message: 'ID do orçamento não retornado pela API.',
          );
        }
        return;
      }

      Modular.to.pushReplacementNamed('/budget/config/$budgetId');
    } else if (store.error != null && mounted) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.error,
        title: 'Erro ao criar orçamento',
        message: store.error!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(
        title: 'Censo escolar',
        showBackButton: true,
        actionButton: GestureDetector(
          onTap: _showCitySelectionModal,
          child: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: const Color(0xFF117BBD),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF117BBD),
                width: 2,
              ),
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
        child: Observer(
          builder: (context) {
            if (store.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCityBadges(),
                        if (store.quantidadeCidades > 1) ...[
                          SizedBox(height: 16.h),
                          CitySelectorDropdown(
                            cities: store.selectedCities.toList(),
                            selectedCityId: store.selectedCityId,
                            onCitySelected: store.selectCity,
                          ),
                        ],
                        SizedBox(height: 16.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            'Informe os valores nos campos designados ou escolha cidades para buscar valores',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF828282),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        _buildCensusSections(),
                      ],
                    ),
                  ),
                ),
                _buildNextButton(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCityBadges() {
    return Observer(
      builder: (context) {
        if (store.selectedCities.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: store.selectedCities.map((cityData) {
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: CityBadgeWidget(
                    city: cityData['nome'] ?? '',
                    state: cityData['uf'] ?? '',
                    onRemove: () {
                      store.removeCity(cityData['id'] as int);
                      if (store.hasCities) {
                        store.loadCensusForCities();
                      }
                    },
                    showIcon: true,
                    backgroundColor: const Color(0xFF00364D),
                    textColor: const Color(0xFFEBF9FF),
                    iconBackgroundColor: const Color(0xFFEBF9FF),
                    iconColor: const Color(0xFF00364D),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCensusSections() {
    return Observer(
      builder: (context) {
        final census = store.currentCensus;

        if (census == null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.h),
              child: Text(
                'Adicione cidades para visualizar os dados do censo',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final studentGroups = census.grupos
            .map((group) {
              final studentTitles = group.titulos
                  .where((title) => !title.nomeEtapa.endsWith('P'))
                  .toList();
              if (studentTitles.isEmpty) return null;
              return group.copyWith(titulos: studentTitles);
            })
            .nonNulls
            .toList();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...studentGroups.map((group) {
                _syncControllersWithStore();
                return CensusDataSectionWidget.withNomeEtapa(
                  group: group,
                  isEditMode: !store.isAggregateMode,
                  controllers: _controllers,
                  onItemChanged: (entry) {
                    final cityId = store.selectedCityId ??
                        (store.cidadeIds.isNotEmpty
                            ? store.cidadeIds.first
                            : 0);
                    _onValueChanged(cityId, entry.key, entry.value);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNextButton() {
    return Observer(
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          child: ElevatedButton(
            onPressed: store.hasCities && !store.isSaving ? _handleNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E3562),
              disabledBackgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 14.h),
            ),
            child: store.isSaving
                ? SizedBox(
                    width: 20.sp,
                    height: 20.sp,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Próximo',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: store.hasCities ? Colors.white : Colors.grey,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.arrow_forward,
                        color: store.hasCities ? Colors.white : Colors.grey,
                        size: 18.sp,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
