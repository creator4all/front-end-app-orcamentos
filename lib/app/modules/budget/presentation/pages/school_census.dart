import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/entities/censo_entity.dart';
import 'package:multimidiaapp/services/censo_service.dart';

import '../../../../shared/widgets/custom_top_bar.dart';

class SchoolCensusPage extends StatefulWidget {
  const SchoolCensusPage({super.key});

  @override
  State<SchoolCensusPage> createState() => _SchoolCensusPageState();
}

class _SchoolCensusPageState extends State<SchoolCensusPage>
    with WidgetsBindingObserver {
  bool _isEditMode = false;
  CensoData? _censo;
  bool _isSaving = false;
  bool _needsReload = false;
  bool _needsToReturnUpdatedData = false;
  CensoData? _updatedCensoToReturn;
  final CensoService _censoService = CensoService();
  final FocusNode _pageFocusNode = FocusNode();

  // Controllers for text fields in edit mode
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Set up focus node listener to detect when page gets focus again
    _pageFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_pageFocusNode.hasFocus && _needsReload) {
      _reloadCensoData();
      _needsReload = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app resumes from background, mark for reload
    if (state == AppLifecycleState.resumed) {
      _needsReload = true;
      if (mounted) {
        _reloadCensoData();
        _needsReload = false;
      }
    }
  }

  /// Reload data directly from API
  Future<void> _reloadCensoData() async {
    if (_censo?.cidadeData?.id == null) return;

    try {
      final updatedCenso =
          await _censoService.censoPorCidade(_censo!.cidadeData!.id);
      if (mounted) {
        setState(() {
          _censo = updatedCenso;
          _clearAndRecreateControllers();
        });
      }
    } catch (e) {
      developer.log('Erro ao recarregar dados do censo: ${e.toString()}');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCensoData();
  }

  /// Load or refresh censo data from arguments
  void _loadCensoData() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['censo'] is CensoData) {
      _censo = args['censo'] as CensoData;

      // Always clear and recreate controllers to ensure fresh values
      _clearAndRecreateControllers();
      setState(() {});
    }
  }

  void _clearAndRecreateControllers() {
    // First dispose existing controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();

    // Then recreate with fresh values
    for (final indice
        in _censo?.cidadeData?.indicesEtapa ?? const <CidadeIndice>[]) {
      final key = 'indice_${indice.indiceEtapaId}';
      _controllers.putIfAbsent(
          key, () => TextEditingController(text: indice.valor.toString()));
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }

    // Remove observers and listeners
    _pageFocusNode.removeListener(_onFocusChange);
    _pageFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
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
            onTap: () {
              setState(() {
                _isEditMode = !_isEditMode;
              });

              // Force rebuild the indices section when toggling edit mode
              setState(() {});
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 56.w,
              height: 32.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: _isEditMode
                    ? const Color(0xFF117BBD)
                    : const Color(0xFFE0E0E0),
                boxShadow: _isEditMode
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
                  // Background icon/text
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isEditMode ? 1.0 : 0.0,
                    child: Center(
                      child: Icon(
                        Icons.edit,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Animated circle
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: _isEditMode ? 26.w : 2.w,
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
                        child: _isEditMode
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
            (_censo?.totalStudents ?? 0).toString(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Ano do censo escolar',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          if (_censo == null)
            Text(
              'Dados do censo indisponíveis',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          Text(
            _censo?.censusYear ?? '',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicesSection() {
    // Get all indices from censo data
    final allIndices = _censo?.cidadeData?.indicesEtapa ?? <CidadeIndice>[];

    // Group indices by grupo_id
    final Map<int, List<CidadeIndice>> groupedIndices = {};

    for (var indice in allIndices) {
      final grupoId = indice.grupo?.grupoId ?? 0;
      if (!groupedIndices.containsKey(grupoId)) {
        groupedIndices[grupoId] = [];
      }
      groupedIndices[grupoId]!.add(indice);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          ...groupedIndices.entries.map((entry) {
            final indices = entry.value;
            final grupoName = indices.isNotEmpty && indices.first.grupo != null
                ? indices.first.grupo!.nomeGrupo
                : 'Outros Índices';

            // Format the group name with prefix if it doesn't already have one
            final displayName = grupoName.toLowerCase().contains('grupo')
                ? grupoName
                : 'Grupo: $grupoName';

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
                ...indices.map((indice) {
                  final key = 'indice_${indice.indiceEtapaId}';
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h, left: 8.w),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            indice.nomeEtapa,
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
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                  opacity: animation, child: child);
                            },
                            child: _isEditMode
                                ? TextField(
                                    key: ValueKey('edit_$key'),
                                    controller: _controllers[key],
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    textAlign: TextAlign.right,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 6.h,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.r),
                                        borderSide: BorderSide(
                                            color: Colors.grey[300]!),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.r),
                                        borderSide: BorderSide(
                                            color: Colors.grey[300]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.r),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF117BBD)),
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  )
                                : Text(
                                    key: ValueKey('text_$key'),
                                    'R\$ ${indice.valor.toStringAsFixed(2)}',
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
                }),
                SizedBox(height: 16.h), // Add spacing between groups
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Coleta os valores atualizados dos índices a partir dos controllers
  Map<int, double> _getUpdatedIndices() {
    final Map<int, double> updatedIndices = {};

    for (final entry in _controllers.entries) {
      // Extrai o ID do índice da chave (formato: 'indice_ID')
      final id = int.tryParse(entry.key.split('_')[1]);
      if (id != null) {
        // Converte o valor do texto para double
        final value = double.tryParse(entry.value.text);
        if (value != null && value > 0) {
          updatedIndices[id] = value;
        }
      }
    }

    return updatedIndices;
  }

  /// Salva os índices atualizados
  Future<void> _saveIndices() async {
    if (_censo?.cidadeData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados de cidade não encontrados!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cidadeId = _censo!.cidadeData!.id;
    final updatedIndices = _getUpdatedIndices();

    if (updatedIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma alteração detectada!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _censoService.atualizarIndicesCidade(cidadeId, updatedIndices);

      // Depois de salvar com sucesso, recarrega os dados do censo para ter os valores atualizados
      try {
        final updatedCenso = await _censoService.censoPorCidade(cidadeId);
        setState(() {
          _censo = updatedCenso;
          _isEditMode = false; // Desativa modo edição
          _clearAndRecreateControllers(); // Recria os controllers com valores atualizados
        });

        // Store the updated censo to return when navigating back
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _needsToReturnUpdatedData = true;
            _updatedCensoToReturn = updatedCenso;
          }
        });
      } catch (e) {
        developer.log(
            'Aviso: Não foi possível recarregar os dados do censo após salvar: ${e.toString()}');
        // Mesmo com erro de recarga, desativamos o modo edição
        setState(() {
          _isEditMode = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Censo escolar salvo com sucesso!'),
          backgroundColor: Color(0xFF56B34A),
        ),
      );
      // Já atualizamos o _isEditMode na operação acima
    } catch (e) {
      developer.log('Erro ao salvar índices: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: SizedBox(
        width: double.infinity,
        height: 40.h,
        child: ElevatedButton.icon(
          onPressed: _isSaving ? null : _saveIndices,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF56B34A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            disabledBackgroundColor: Colors.grey,
          ),
          icon: _isSaving
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
            _isSaving ? 'Salvando...' : 'Salvar',
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
    return WillPopScope(
      onWillPop: () async {
        // If we have updated data to return, pass it back
        if (_needsToReturnUpdatedData && _updatedCensoToReturn != null) {
          Navigator.of(context).pop({'updatedCenso': _updatedCensoToReturn});
          return false; // We handled the pop ourselves
        }
        return true; // Allow default pop behavior
      },
      child: Focus(
        focusNode: _pageFocusNode,
        child: Scaffold(
          appBar: const CustomTopBar(
            title: 'Censo Escolar',
            showBackButton: true,
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _reloadCensoData,
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
            ),
          ),
        ),
      ),
    );
  }
}
