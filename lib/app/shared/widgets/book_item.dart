import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookItem extends StatelessWidget {
  final String title;
  final String value;
  final String quantity;
  final bool isSelected;
  final ValueChanged<bool?>? onCheckboxChanged;
  final VoidCallback? onTap;

  const BookItem({
    super.key,
    required this.title,
    required this.value,
    required this.quantity,
    this.isSelected = false,
    this.onCheckboxChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: 70.h,
        ),
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF2830F2) : const Color(0xFFD9D9D9),
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: Checkbox(
                  value: isSelected,
                  onChanged: onCheckboxChanged,
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
                    color: isSelected
                        ? const Color(0xFF2830F2)
                        : Colors.grey[300]!,
                    width: 1.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(5),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF000000),
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF484848),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.only(left: 10.w, right: 10.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      quantity,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF000000),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(width: 8.w),

                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16.sp,
                      color: const Color(0xFF000000),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}