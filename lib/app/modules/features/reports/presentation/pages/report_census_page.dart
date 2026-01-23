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

/// Página de visualização do Censo Escolar em modo somente leitura.
///
/// Layout IDÊNTICO ao SchoolCensusPage, mas sem controles de edição:
/// - ❌ Toggle de modo edição
/// - ❌ Botão Salvar
/// - ✅ City Selector (multi-cidade)
/// - ✅ CensusDataSectionWidget
/// - ✅ Separação Alunos/Professores
/// - ✅ Export CSV
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

  // Ano mockado conforme layout original
  static const String _mockYear = '2024';

  @override
  void initState() {
    super.initState();
    _store = Modular.get<SchoolCensusStore>();

    // Definir budgetId e carregar dados via endpoint de orçamento
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
          // Sempre manter sync pois é readonly
          _controllers[title.id]?.text = title.valor.toStringAsFixed(0);
        }
      }
    }
  }

  /// Filtra grupos para mostrar apenas dados de ALUNOS (sem sufixo P)
  List<CensoGroupEntity> _getStudentGroups() {
    final censo = _store.censoEscolar;
    if (censo == null) return [];

    return censo.grupos
        .map((group) {
          final studentTitles = group.titulos
              .where((title) => !title.nomeEtapa.endsWith('P'))
              .toList();
          return CensoGroupEntity(
            id: group.id,
            nome: group.nome,
            titulos: studentTitles,
          );
        })
        .where((group) => group.titulos.isNotEmpty)
        .toList();
  }

  /// Filtra grupos para mostrar apenas dados de PROFESSORES (com sufixo P)
  List<CensoGroupEntity> _getProfessorGroups() {
    final censo = _store.censoEscolar;
    if (censo == null) return [];

    return censo.grupos
        .map((group) {
          final professorTitles = group.titulos
              .where((title) => title.nomeEtapa.endsWith('P'))
              .toList();
          return CensoGroupEntity(
            id: group.id,
            nome: group.nome,
            titulos: professorTitles,
          );
        })
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

            // Sync controllers
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
                    // Seletor de cidade (só para multi-cidade)
                    if (_store.isMultiCity) _buildCitySelector(),

                    // Informação do censo
                    _buildCensusInfo(),

                    SizedBox(height: 16.h),

                    // Seções de Alunos
                    _buildStudentsSections(),

                    // Seções de Professores
                    _buildProfessorsSections(),

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

  /// Dropdown pesquisável para selecionar cidade (apenas multi-cidade)
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
          // Limpar controllers ao trocar de cidade
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
          'Total de alunos: ${_store.totalStudents.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          _mockYear,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentsSections() {
    final studentGroups = _getStudentGroups();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: studentGroups
          .map((group) => CensusDataSectionWidget.withId(
                group: group,
                isEditMode: false, // ✅ Sempre readonly
                controllers: _controllers,
                onItemChanged: null, // ✅ Sem callback de edição
              ))
          .toList(),
    );
  }

  Widget _buildProfessorsSections() {
    final professorGroups = _getProfessorGroups();

    // Só exibe seção de professores se houver dados
    if (professorGroups.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Text(
          'Professores',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF117BBD),
          ),
        ),
        SizedBox(height: 8.h),
        ...professorGroups.map((group) => CensusDataSectionWidget.withId(
              group: group,
              isEditMode: false, // ✅ Sempre readonly
              controllers: _controllers,
              onItemChanged: null, // ✅ Sem callback de edição
            )),
      ],
    );
  }
}
