import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VideoThumbnailWidget extends StatelessWidget {
  final String thumbnailUrl;
  final double width;
  final double height;

  const VideoThumbnailWidget({
    super.key,
    required this.thumbnailUrl,
    this.width = 60,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.w,
      height: height.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        image: DecorationImage(
          image: NetworkImage(thumbnailUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Container(
          width: 24.w,
          height: 24.h,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 16.sp,
          ),
        ),
      ),
    );
  }
}
