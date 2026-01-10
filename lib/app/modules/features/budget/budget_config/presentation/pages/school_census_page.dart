import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_info_dialog.dart';

import '../../../../../../shared/widgets/custom_top_bar.dart';
import '../../../../../../shared/widgets/searchable_dropdown_widget.dart';
import '../../domain/entities/censo_escolar_entity.dart';
import '../../domain/entities/censo_group_entity.dart';
import '../stores/school_census_store.dart';
import '../widgets/census_data_section_widget.dart';

class SchoolCensusPage extends StatefulWidget {
  final int cityId;
  final int? budgetId;
  final CensoEscolarEntity? censoInicial;
  final Function(CensoEscolarEntity)? onCensusUpdated;

  /// Indica se deve usar modo multi-cidade (carregar via loadBudgetCensus)
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

  // Ano mockado conforme solicitado
  static const String _mockYear = '2024';

  @override
  void initState() {
    super.initState();

    // Definir budgetId para usar endpoint budget-scoped
    if (widget.budgetId != null) {
      store.setBudgetId(widget.budgetId);
    }

    // Se é modo multi-cidade, carregar via endpoint de orçamento
    if (widget.isMultiCityMode && widget.budgetId != null) {
      store.loadBudgetCensus(widget.budgetId!).then((_) {
        // Mostrar dialog informativo se estiver em modo multi-cidade e visualização agregada
        if (store.isMultiCity && store.isAggregatedView) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showInfoDialog();
          });
        }
      });
    } else if (widget.censoInicial != null) {
      // Se recebeu dados do censo, usar diretamente
      store.setCensoEscolar(widget.censoInicial!);
    } else {
      // Caso contrário, carregar da API por cidade
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

  /// Filtra grupos para mostrar apenas dados de ALUNOS (sem sufixo P)
  List<CensoGroupEntity> _getStudentGroups() {
    final censo = store.censoEscolar;
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
    final censo = store.censoEscolar;
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
          actionButton: store.isMultiCity
              ? IconButton(
                  onPressed: _showInfoDialog,
                  icon: Icon(
                    Icons.info_outline,
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

              // Sync controllers
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
                            // Seletor de cidade (só para multi-cidade)
                            if (store.isMultiCity) _buildCitySelector(),

                            // Toggle de edição (oculto no modo agregado)
                            if (!store.isAggregatedView) _buildEditModeToggle(),

                            // Informação do censo
                            _buildCensusInfo(),

                            // Aviso de modo agregado (REMOVIDO EM FAVOR DO DIALOG)
                            // if (store.isAggregatedView) _buildAggregatedModeWarning(),

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

  /// Dropdown pesquisável para selecionar cidade (apenas multi-cidade)
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
          // Limpar controllers ao trocar de cidade
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
          .map((group) => CensusDataSectionWidget.withId(
                group: group,
                isEditMode: store.isEditMode && !store.isAggregatedView,
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
        ...professorGroups.map((group) => CensusDataSectionWidget.withId(
              group: group,
              isEditMode: store.isEditMode && !store.isAggregatedView,
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

      // Notificar parent sobre atualização do censo
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
}
