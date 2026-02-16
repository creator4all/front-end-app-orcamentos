import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CensusInputRowWidget extends StatelessWidget {
  final String label;
  final double value;
  final bool isEditMode;
  final TextEditingController? controller;
  final ValueChanged<double>? onChanged;

  const CensusInputRowWidget({
    super.key,
    required this.label,
    required this.value,
    required this.isEditMode,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
            width: 80.w,
            child: isEditMode ? _buildTextField() : _buildTextValue(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextValue() {
    return Text(
      value.toStringAsFixed(0),
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: controller,
      onChanged: (text) {
        final parsed = double.tryParse(text);
        if (parsed != null && parsed >= 0 && onChanged != null) {
          onChanged!(parsed);
        }
      },
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 8.w,
          vertical: 8.h,
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
          borderSide: const BorderSide(color: Color(0xFF117BBD)),
        ),
      ),
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
    );
  }
}
