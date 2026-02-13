import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_info_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../../shared/widgets/custom_top_bar.dart';
import '../../../../../../shared/widgets/searchable_dropdown_widget.dart';
import '../../domain/entities/censo_escolar_entity.dart';
import '../../domain/entities/censo_group_entity.dart';
import '../../domain/repositories/census_repository.dart';
import '../stores/school_census_store.dart';
import '../widgets/census_data_section_widget.dart';

class SchoolCensusPage extends StatefulWidget {
  final int cityId;
  final int? budgetId;
  final CensoEscolarEntity? censoInicial;
  final Function(CensoEscolarEntity)? onCensusUpdated;

  final bool isMultiCityMode;

  const SchoolCensusPage({
    super.key,
    required this.cityId,
    this.budgetId,
    this.censoInicial,
    this.onCensusUpdated,
    this.isMultiCityMode = false,
  });

  @override
  State<SchoolCensusPage> createState() => _SchoolCensusPageState();
}

class _SchoolCensusPageState
    extends ModularState<SchoolCensusPage, SchoolCensusStore> {
  final Map<int, TextEditingController> _controllers = {};
  bool _hasSavedChanges = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();

    if (widget.budgetId != null) {
      store.setBudgetId(widget.budgetId);
    }

    if (widget.isMultiCityMode && widget.budgetId != null) {
      store.loadBudgetCensus(widget.budgetId!).then((_) {
        if (store.isMultiCity && store.isAggregatedView) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showInfoDialog();
          });
        }
      });
    } else if (widget.censoInicial != null) {
      store.setCensoEscolar(widget.censoInicial!);
    } else {
      store.loadCensus(widget.cityId);
    }
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

  List<CensoGroupEntity> _getStudentGroups() {
    final censo = store.censoEscolar;
    if (censo == null) return [];

    return censo.grupos
        .map((group) {
          final studentTitles =
              group.titulos
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

  List<CensoGroupEntity> _getProfessorGroups() {
    final censo = store.censoEscolar;
    if (censo == null) return [];

    return censo.grupos
        .map((group) {
          final professorTitles =
              group.titulos
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

  void _showInfoDialog() {
    CustomInfoDialog.show(
      context: context,
      type: DialogType.info,
      title: 'Informação sobre o Censo',
      message:
          'Você está visualizando a soma dos alunos de todas as cidades selecionadas.\n\nPara editar os valores, selecione uma cidade específica no menu acima.',
    );
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
        appBar: CustomTopBar(
          title: 'Censo escolar',
          showBackButton: true,
          actionButton:
              widget.budgetId != null
                  ? IconButton(
                    onPressed: _isExporting ? null : _handleExportCsv,
                    icon:
                        _isExporting
                            ? SizedBox(
                              width: 20.sp,
                              height: 20.sp,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF117BBD),
                              ),
                            )
                            : Icon(
                              Icons.share,
                              color: const Color(0xFF117BBD),
                              size: 24.sp,
                            ),
                  )
                  : null,
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
                        onPressed: () => _retryLoad(),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                );
              }

              if (store.censoEscolar == null) {
                return const Center(child: Text('Nenhum dado encontrado'));
              }

              _syncControllersWithStore();

              return Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => _retryLoad(),
                      color: const Color(0xFF117BBD),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (store.isMultiCity) _buildCitySelector(),

                            if (!store.isAggregatedView) _buildEditModeToggle(),

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
                  if (store.isEditMode && !store.isAggregatedView)
                    _buildSaveButton(),
                ],
              );
            },
          ),
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
        value: store.selectedCityName,
        items: store.cityOptions.map((e) => e.name).toList(),
        onChanged: (cityName) {
          if (cityName == null) return;

          final selectedOption = store.cityOptions.firstWhere(
            (option) => option.name == cityName,
            orElse: () => store.cityOptions.first,
          );

          store.selectCity(selectedOption.id);
          _controllers.clear();
        },
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
                color:
                    store.isEditMode
                        ? const Color(0xFF117BBD)
                        : const Color(0xFFE0E0E0),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment:
                    store.isEditMode
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
          store.censoEscolar?.censoAno?.toString() ?? '-',
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
      children:
          studentGroups
              .map(
                (group) => CensusDataSectionWidget.withId(
                  group: group,
                  isEditMode: store.isEditMode && !store.isAggregatedView,
                  controllers: _controllers,
                  onItemChanged: (entry) {
                    store.updateValue(entry.key, entry.value);
                  },
                ),
              )
              .toList(),
    );
  }

  Widget _buildProfessorsSections() {
    final professorGroups = _getProfessorGroups();

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
        ...professorGroups.map(
          (group) => CensusDataSectionWidget.withId(
            group: group,
            isEditMode: store.isEditMode && !store.isAggregatedView,
            controllers: _controllers,
            onItemChanged: (entry) {
              store.updateValue(entry.key, entry.value);
            },
          ),
        ),
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
        child:
            store.isSaving
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

  Future<void> _retryLoad() async {
    if (widget.isMultiCityMode && widget.budgetId != null) {
      await store.loadBudgetCensus(widget.budgetId!);
    } else {
      await store.loadCensus(widget.cityId);
    }
  }

  Future<void> _handleSave() async {
    await store.saveCensus();
    if (store.error == null) {
      _hasSavedChanges = true;

      if (store.censoEscolar != null) {
        widget.onCensusUpdated?.call(store.censoEscolar!);
      }

      if (mounted) {
        await CustomInfoDialog.show(
          context: context,
          type: DialogType.success,
          title: 'Sucesso',
          message: 'Censo escolar salvo com sucesso!',
        );
      }
    } else {
      if (mounted) {
        CustomInfoDialog.show(
          context: context,
          type: DialogType.error,
          title: 'Erro ao salvar',
          message: 'Erro ao salvar: ${store.error}',
        );
      }
    }
  }

  Future<void> _handleExportCsv() async {
    if (widget.budgetId == null) return;

    setState(() => _isExporting = true);

    try {
      final repository = Modular.get<CensusRepository>();
      final result = await repository.exportCensusCsv(widget.budgetId!);

      result.fold(
        (failure) {
          if (mounted) {
            CustomInfoDialog.show(
              context: context,
              type: DialogType.error,
              title: 'Erro ao exportar',
              message: failure.message,
            );
          }
        },
        (csvBytes) async {
          try {
            final tempDir = await getTemporaryDirectory();
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final file = File('${tempDir.path}/censo_escolar_$timestamp.csv');
            await file.writeAsBytes(csvBytes);

            await Share.shareXFiles([
              XFile(file.path),
            ], subject: 'Censo Escolar - Orçamento ${widget.budgetId}');
          } catch (e) {
            if (mounted) {
              CustomInfoDialog.show(
                context: context,
                type: DialogType.error,
                title: 'Erro ao compartilhar',
                message: 'Erro ao compartilhar arquivo: $e',
              );
            }
          }
        },
      );
    } catch (e) {
      if (mounted) {
        CustomInfoDialog.show(
          context: context,
          type: DialogType.error,
          title: 'Erro',
          message: 'Erro inesperado: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }
}
