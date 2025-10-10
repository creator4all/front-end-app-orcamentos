import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FileFilterChips extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const FileFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          _buildFilterChip('all', 'Todos', Icons.grid_view),
          SizedBox(width: 8.w),
          _buildFilterChip('folders', 'Pastas', Icons.folder),
          SizedBox(width: 8.w),
          _buildFilterChip('documents', 'Documentos', Icons.description),
          SizedBox(width: 8.w),
          _buildFilterChip('images', 'Imagens', Icons.image),
          SizedBox(width: 8.w),
          _buildFilterChip('videos', 'Vídeos', Icons.video_library),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = selectedFilter == value;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: isSelected ? Colors.white : const Color(0xFF1C94DF),
          ),
          SizedBox(width: 6.w),
          Text(label),
        ],
      ),
      onSelected: (_) => onFilterChanged(value),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF1C94DF),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 13.sp,
        color: isSelected ? Colors.white : const Color(0xFF484848),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: isSelected ? const Color(0xFF1C94DF) : Colors.grey[300]!,
          width: 1.5,
        ),
      ),
    );
  }
}
