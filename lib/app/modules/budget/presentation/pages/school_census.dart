import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/entities/censo_entity.dart';

import '../../../../shared/widgets/custom_top_bar.dart';

class SchoolCensusPage extends StatefulWidget {
  const SchoolCensusPage({super.key});

  @override
  State<SchoolCensusPage> createState() => _SchoolCensusPageState();
}

class _SchoolCensusPageState extends State<SchoolCensusPage> {
  bool _isEditMode = false;
  CensoData? _censo;

  // Controllers for text fields in edit mode
  final Map<String, TextEditingController> _controllers = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['censo'] is CensoData) {
      _censo = args['censo'] as CensoData;
      for (final group in _censo?.groups ?? const <CensoGroup>[]) {
        for (final item in group.items) {
          final key = '${group.name}_${item.name}';
          _controllers.putIfAbsent(
              key, () => TextEditingController(text: item.value.toString()));
        }
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
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

  Widget _buildGroupSection(CensoGroup group) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          Text(
            group.name,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF117BBD),
            ),
          ),
          SizedBox(height: 12.h),
          ...group.items.map<Widget>((item) {
            final key = '${group.name}_${item.name}';
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _isEditMode
                        ? TextField(
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
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.r),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
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
                            item.value.toString(),
                            textAlign: TextAlign.right,
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Censo escolar salvo com sucesso!'),
                backgroundColor: Color(0xFF56B34A),
              ),
            );
            setState(() {
              _isEditMode = false;
            });
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
      appBar: const CustomTopBar(
        title: 'Censo Escolar',
        showBackButton: true,
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
                    _buildEditModeToggle(),
                    const SizedBox(height: 8),
                    _buildCensusInfo(),
                    ...((_censo?.groups ?? <CensoGroup>[]))
                        .map<Widget>((group) => _buildGroupSection(group)),
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
