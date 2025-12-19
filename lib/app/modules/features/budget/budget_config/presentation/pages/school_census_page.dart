import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../shared/widgets/custom_top_bar.dart';
import '../../domain/entities/censo_group_entity.dart';
import '../stores/school_census_store.dart';
import '../widgets/census_data_section_widget.dart';

class SchoolCensusPage extends StatefulWidget {
  final int cityId;

  const SchoolCensusPage({
    super.key,
    required this.cityId,
  });

  @override
  State<SchoolCensusPage> createState() => _SchoolCensusPageState();
}

class _SchoolCensusPageState
    extends ModularState<SchoolCensusPage, SchoolCensusStore> {
  final Map<int, TextEditingController> _controllers = {};
  bool _hasSavedChanges = false;

  // Ano mockado conforme solicitado
  static const String _mockYear = '2024';

  @override
  void initState() {
    super.initState();
    store.loadCensus(widget.cityId);
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncControllersWithStore() {
    final censo = store.censoEscolar;
    if (censo == null) return;

    for (var group in censo.grupos) {
      for (var title in group.titulos) {
        if (!_controllers.containsKey(title.id)) {
          _controllers[title.id] = TextEditingController(
            text: title.valor.toStringAsFixed(0),
          );
        } else if (!store.isEditMode) {
          _controllers[title.id]?.text = title.valor.toStringAsFixed(0);
        }
      }
    }
  }

  /// Filtra grupos para mostrar apenas dados de ALUNOS (sem sufixo P)
  List<CensoGroupEntity> _getStudentGroups() {
    final censo = store.censoEscolar;
    if (censo == null) return [];

    return censo.grupos.map((group) {
      final studentTitles = group.titulos
          .where((title) => !title.nomeEtapa.endsWith('P'))
          .toList();
      return CensoGroupEntity(
        id: group.id,
        nome: group.nome,
        titulos: studentTitles,
      );
    }).where((group) => group.titulos.isNotEmpty).toList();
  }

  /// Filtra grupos para mostrar apenas dados de PROFESSORES (com sufixo P)
  List<CensoGroupEntity> _getProfessorGroups() {
    final censo = store.censoEscolar;
    if (censo == null) return [];

    return censo.grupos.map((group) {
      final professorTitles = group.titulos
          .where((title) => title.nomeEtapa.endsWith('P'))
          .toList();
      return CensoGroupEntity(
        id: group.id,
        nome: group.nome,
        titulos: professorTitles,
      );
    }).where((group) => group.titulos.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.of(context).pop(_hasSavedChanges);
        }
      },
      child: Scaffold(
        appBar: const CustomTopBar(
          title: 'Censo escolar',
          showBackButton: true,
        ),
        body: SafeArea(
          child: Observer(
            builder: (context) {
              if (store.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (store.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Erro: ${store.error}'),
                      ElevatedButton(
                        onPressed: () => store.loadCensus(widget.cityId),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                );
              }

              if (store.censoEscolar == null) {
                return const Center(child: Text('Nenhum dado encontrado'));
              }

              // Sync controllers
              _syncControllersWithStore();

              return Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => store.loadCensus(widget.cityId),
                      color: const Color(0xFF117BBD),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEditModeToggle(),
                            _buildCensusInfo(),
                            SizedBox(height: 16.h),
                            _buildStudentsSections(),
                            _buildProfessorsSections(),
                            SizedBox(height: 16.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (store.isEditMode) _buildSaveButton(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEditModeToggle() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: store.toggleEditMode,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 44.w,
              height: 24.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: store.isEditMode
                    ? const Color(0xFF117BBD)
                    : const Color(0xFFE0E0E0),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: store.isEditMode
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 20.w,
                  height: 20.h,
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'Modo de edição',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCensusInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total de alunos: ${store.totalStudents.toStringAsFixed(0)}',
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
          .map((group) => CensusDataSectionWidget(
                group: group,
                isEditMode: store.isEditMode,
                controllers: _controllers,
                onItemChanged: (entry) {
                  store.updateValue(entry.key, entry.value);
                },
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
        ...professorGroups.map((group) => CensusDataSectionWidget(
              group: group,
              isEditMode: store.isEditMode,
              controllers: _controllers,
              onItemChanged: (entry) {
                store.updateValue(entry.key, entry.value);
              },
            )),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      child: ElevatedButton(
        onPressed: store.isSaving ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF56B34A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          disabledBackgroundColor: Colors.grey,
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
            : Text(
                'Salvar',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _handleSave() async {
    await store.saveCensus();
    if (store.error == null) {
      _hasSavedChanges = true;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Censo escolar salvo com sucesso!'),
            backgroundColor: Color(0xFF56B34A),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: ${store.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
