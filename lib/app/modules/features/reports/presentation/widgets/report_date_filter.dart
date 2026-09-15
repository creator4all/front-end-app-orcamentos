import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ReportDateFilter extends StatelessWidget {
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final Function(DateTime?) onDataInicioChanged;
  final Function(DateTime?) onDataFimChanged;
  final VoidCallback? onClear;

  const ReportDateFilter({
    super.key,
    this.dataInicio,
    this.dataFim,
    required this.onDataInicioChanged,
    required this.onDataFimChanged,
    this.onClear,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime? currentDate,
    Function(DateTime?) onDateChanged, {
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final now = DateTime.now();
    final first = firstDate ?? DateTime(2020);
    final last = lastDate ?? now.add(const Duration(days: 365));
    final initial = currentDate ?? now;
    final selected = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first)
          ? first
          : initial.isAfter(last)
              ? last
              : initial,
      firstDate: first,
      lastDate: last,
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0E3562),
              onPrimary: Colors.white,
              onSurface: Color(0xFF484848),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      onDateChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFilter = dataInicio != null || dataFim != null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE0E0E0),
            width: 1.h,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDateField(
              context: context,
              label: 'Data início',
              value: dataInicio,
              onTap: () => _selectDate(
                context,
                dataInicio,
                onDataInicioChanged,
                lastDate:
                    dataFim ?? DateTime.now().add(const Duration(days: 365)),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildDateField(
              context: context,
              label: 'Data fim',
              value: dataFim,
              onTap: () => _selectDate(
                context,
                dataFim,
                onDataFimChanged,
                firstDate: dataInicio ?? DateTime(2020),
              ),
            ),
          ),
          if (hasFilter && onClear != null) ...[
            SizedBox(width: 8.w),
            IconButton(
              onPressed: onClear,
              icon: Icon(
                Icons.clear,
                size: 20.w,
                color: const Color(0xFF828282),
              ),
              tooltip: 'Limpar filtros',
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: 32.w,
                minHeight: 32.w,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: value != null
                ? const Color(0xFF0E3562)
                : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16.w,
              color: value != null
                  ? const Color(0xFF0E3562)
                  : const Color(0xFF828282),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                value != null ? _formatDate(value) : label,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: value != null
                      ? const Color(0xFF484848)
                      : const Color(0xFF828282),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
