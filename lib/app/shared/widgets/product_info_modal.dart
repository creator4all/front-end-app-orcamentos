import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'custom_modal.dart';

/// Modal de informações do produto
class ProductInfoModal extends StatefulWidget {
  final Map<String, String> productInfo;
  final List<CheckboxGroup> checkboxGroups;
  final String unitValue;
  final VoidCallback? onSave;

  const ProductInfoModal({
    super.key,
    required this.productInfo,
    required this.checkboxGroups,
    required this.unitValue,
    this.onSave,
  });

  /// Método estático para exibir o modal
  static Future<T?> show<T>({
    required BuildContext context,
    required Map<String, String> productInfo,
    required List<CheckboxGroup> checkboxGroups,
    required String unitValue,
    VoidCallback? onSave,
  }) {
    return CustomModal.show<T>(
      context: context,
      title: 'Informações do Produto',
      content: ProductInfoModal(
        productInfo: productInfo,
        checkboxGroups: checkboxGroups,
        unitValue: unitValue,
        onSave: onSave,
      ),
    );
  }

  @override
  State<ProductInfoModal> createState() => _ProductInfoModalState();
}

class _ProductInfoModalState extends State<ProductInfoModal> {
  late TextEditingController _valueController;
  late List<CheckboxGroup> _checkboxGroups;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController();
    _checkboxGroups = widget.checkboxGroups
        .map((group) => CheckboxGroup(
              title: group.title,
              items: group.items
                  .map((item) => CheckboxItem(
                        label: item.label,
                        isSelected: item.isSelected,
                      ))
                  .toList(),
            ))
        .toList();
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Container com informações do produto
        _buildProductInfoContainer(),

        SizedBox(height: 16.h),

        // Grupos de checkbox
        ..._buildCheckboxGroups(),

        SizedBox(height: 16.h),

        // Campo de valor unitário
        _buildUnitValueField(),

        SizedBox(height: 24.h),

        // Botão de salvar
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildProductInfoContainer() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD9D9D9)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.productInfo.entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${entry.key}: ',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF000000),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: entry.value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF000000),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildCheckboxGroups() {
    return _checkboxGroups.map((group) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título do grupo
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text(
              group.title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF000000),
              ),
            ),
          ),

          // Itens do checkbox
          ...group.items.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  // Checkbox usando o widget nativo como os outros componentes
                  SizedBox(
                    width: 17.w,
                    height: 17.h,
                    child: Checkbox(
                      value: item.isSelected,
                      onChanged: (value) {
                        setState(() {
                          item.isSelected = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF2830F2),
                      checkColor: Colors.white,
                      fillColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return const Color(0xFF2830F2);
                          }
                          return Colors.white;
                        },
                      ),
                      side: BorderSide(
                        color: item.isSelected
                            ? const Color(0xFF2830F2)
                            : const Color(0xFFD9D9D9),
                        width: 1.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Texto
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          item.isSelected = !item.isSelected;
                        });
                      },
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          SizedBox(height: 16.h),
        ],
      );
    }).toList();
  }

  Widget _buildUnitValueField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Valor unitário: ${widget.unitValue}',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF000000),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _valueController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Informe o valor',
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF999999),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF2830F2)),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: widget.onSave,
        icon: Icon(
          Icons.save,
          color: Colors.white,
          size: 20.sp,
        ),
        label: Text(
          'Salvar',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF56B34A),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

/// Classe para representar um grupo de checkbox
class CheckboxGroup {
  final String title;
  final List<CheckboxItem> items;

  CheckboxGroup({
    required this.title,
    required this.items,
  });
}

/// Classe para representar um item de checkbox
class CheckboxItem {
  final String label;
  bool isSelected;
  final dynamic data; // Campo para armazenar dados adicionais (ex: indicadores)

  CheckboxItem({
    required this.label,
    this.isSelected = false,
    this.data,
  });
}
