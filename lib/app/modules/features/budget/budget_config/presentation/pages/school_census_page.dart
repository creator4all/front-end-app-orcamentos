import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../shared/widgets/custom_top_bar.dart';
import '../../domain/entities/censo_title_entity.dart';
import '../stores/school_census_store.dart';

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
            text: title.valor.toStringAsFixed(2),
          );
        } else if (!store.isEditMode) {
          _controllers[title.id]?.text = title.valor.toStringAsFixed(2);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_hasSavedChanges);
        return false;
      },
      child: Scaffold(
        appBar: const CustomTopBar(
          title: 'Censo Escolar',
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
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEditModeToggle(),
                            const SizedBox(height: 8),
                            _buildCensusInfo(),
                            _buildIndicesSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildSaveButton(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEditModeToggle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Modo de edição',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          GestureDetector(
            onTap: store.toggleEditMode,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 56.w,
              height: 32.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: store.isEditMode
                    ? const Color(0xFF117BBD)
                    : const Color(0xFFE0E0E0),
                boxShadow: store.isEditMode
                    ? [
                        BoxShadow(
                          color: const Color(0xFF117BBD).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Stack(
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: store.isEditMode ? 1.0 : 0.0,
                    child: Center(
                      child: Icon(
                        Icons.edit,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: store.isEditMode ? 26.w : 2.w,
                    top: 2.h,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28.w,
                      height: 28.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: store.isEditMode
                            ? Icon(
                                Icons.check,
                                key: const ValueKey('check'),
                                size: 16.sp,
                                color: const Color(0xFF117BBD),
                              )
                            : Icon(
                                Icons.edit_off,
                                key: const ValueKey('edit_off'),
                                size: 16.sp,
                                color: Colors.grey[600],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCensusInfo() {
    // Assuming we don't have year in CensoEscolarEntity?
    // CensoEscolarEntity has cidadeId, cidadeNome, grupos, valoresPorEtapa.
    // Legacy CensoData has censusYear.
    // If Entity doesn't have it, we might lose this info or need to add it.
    // Checking previous Entity definition: NO YEAR.
    // Just omitting year or hardcoding if not available?
    // Or maybe it's in a header somewhere?
    // For now omitting year if not in entity.

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total de alunos',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            store.totalStudents.toStringAsFixed(0), // Count is usually int
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          // Removing Year section as it is not in Entity
        ],
      ),
    );
  }

  Widget _buildIndicesSection() {
    final groups = store.censoEscolar?.grupos ?? [];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          ...groups.map((group) {
            final displayName = group.nome.toLowerCase().contains('grupo')
                ? group.nome
                : 'Grupo: ${group.nome}';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                  margin: EdgeInsets.only(bottom: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF117BBD).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF117BBD),
                    ),
                  ),
                ),
                ...group.titulos.map((title) {
                  return _buildIndexItem(title);
                }),
                SizedBox(height: 16.h),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildIndexItem(CensoTitleEntity title) {
    // Ensure controller exists
    if (!_controllers.containsKey(title.id)) {
      _controllers[title.id] =
          TextEditingController(text: title.valor.toStringAsFixed(2));
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 8.w),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title.tituloExibicao,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: store.isEditMode
                  ? TextField(
                      key: ValueKey('edit_${title.id}'),
                      controller: _controllers[title.id],
                      onChanged: (value) {
                        final dValue = double.tryParse(value);
                        if (dValue != null) {
                          store.updateValue(title.id, dValue);
                        }
                      },
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
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
                          borderSide:
                              const BorderSide(color: Color(0xFF117BBD)),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    )
                  : Text(
                      key: ValueKey('text_${title.id}'),
                      'R\$ ${title.valor.toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
            ),
          ),
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
          onPressed: store.isSaving ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF56B34A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            disabledBackgroundColor: Colors.grey,
          ),
          icon: store.isSaving
              ? SizedBox(
                  width: 18.sp,
                  height: 18.sp,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(
                  Icons.save,
                  size: 18.sp,
                  color: Colors.white,
                ),
          label: Text(
            store.isSaving ? 'Salvando...' : 'Salvar',
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
