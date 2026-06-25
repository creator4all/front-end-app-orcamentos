import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../shared/widgets/custom_top_bar.dart';
import '../../../../../shared/widgets/searchable_dropdown_widget.dart';
import '../../../budget/budget_config/data/models/budget_census_dto.dart';
import '../../../budget/budget_config/domain/entities/censo_group_entity.dart';
import '../../../budget/budget_config/presentation/stores/school_census_store.dart';
import '../../../budget/budget_config/presentation/widgets/census_data_section_widget.dart';

class ReportCensusPage extends StatefulWidget {
  final int budgetId;
  final BudgetCensusDto? censoData;

  const ReportCensusPage({
    super.key,
    required this.budgetId,
    this.censoData,
  });

  @override
  State<ReportCensusPage> createState() => _ReportCensusPageState();
}

class _ReportCensusPageState extends State<ReportCensusPage> {
  late final SchoolCensusStore _store;
  final Map<int, TextEditingController> _controllers = {};

  static const String _mockYear = '2024';

  @override
  void initState() {
    super.initState();
    _store = Modular.get<SchoolCensusStore>();

    _store.setBudgetId(widget.budgetId);
    _store.loadBudgetCensus(widget.budgetId);
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncControllersWithStore() {
    final censo = _store.censoEscolar;
    if (censo == null) return;

    for (var group in censo.grupos) {
      for (var title in group.titulos) {
        if (!_controllers.containsKey(title.id)) {
          _controllers[title.id] = TextEditingController(
            text: title.valor.toStringAsFixed(0),
          );
        } else {
          _controllers[title.id]?.text = title.valor.toStringAsFixed(0);
        }
      }
    }
  }

  List<CensoGroupEntity> _getOrderedGroups() {
    final censo = _store.censoEscolar;
    if (censo == null) return [];

    return censo.gruposOrdenados
        .where((group) => group.titulos.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopBar(
        title: 'Censo escolar',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Observer(
          builder: (context) {
            if (_store.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_store.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Erro: ${_store.error}'),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => _store.loadBudgetCensus(widget.budgetId),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            if (_store.censoEscolar == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 48.w,
                      color: const Color(0xFF828282),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Dados do censo não disponíveis',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF828282),
                      ),
                    ),
                  ],
                ),
              );
            }

            _syncControllersWithStore();

            return RefreshIndicator(
              onRefresh: () => _store.loadBudgetCensus(widget.budgetId),
              color: const Color(0xFF117BBD),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_store.isMultiCity) _buildCitySelector(),
                    _buildCensusInfo(),
                    SizedBox(height: 16.h),
                    _buildCensusSections(),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCitySelector() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: SearchableDropdownWidget(
        label: 'Cidade',
        hint: 'Selecione uma cidade',
        searchHint: 'Pesquisar cidade...',
        value: _store.selectedCityName,
        items: _store.cityOptions.map((e) => e.name).toList(),
        onChanged: (cityName) {
          if (cityName == null) return;

          final selectedOption = _store.cityOptions.firstWhere(
            (option) => option.name == cityName,
            orElse: () => _store.cityOptions.first,
          );

          _store.selectCity(selectedOption.id);
          _controllers.clear();
        },
      ),
    );
  }

  Widget _buildCensusInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estudantes: ${_store.totalStudents.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Professores: ${_store.totalProfessores.toStringAsFixed(0)} (quantidade estimada)',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Cursistas: ${_store.totalCursistas.toStringAsFixed(0)} (quantidade estimada)',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Ano do Censo Escolar: ${_store.censoEscolar?.censoAno?.toString() ?? _mockYear}',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildCensusSections() {
    final groups = _getOrderedGroups();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups
          .map((group) => CensusDataSectionWidget.withId(
                group: group,
                isEditMode: false,
                controllers: _controllers,
                onItemChanged: null,
              ))
          .toList(),
    );
  }
}
