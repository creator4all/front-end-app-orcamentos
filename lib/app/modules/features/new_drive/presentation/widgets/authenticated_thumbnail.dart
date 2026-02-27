import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/core/http/app_http_client.dart';

class AuthenticatedThumbnail extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;

  const AuthenticatedThumbnail({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  State<AuthenticatedThumbnail> createState() => _AuthenticatedThumbnailState();
}

class _AuthenticatedThumbnailState extends State<AuthenticatedThumbnail> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final httpClient = Modular.get<AppHttpClient>();
      final bytes = await httpClient.getBytes(widget.url);

      setState(() {
        _imageBytes = Uint8List.fromList(bytes);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: const Color(0xFFDEE1E6),
        child: Center(
          child: SizedBox(
            width: 24.sp,
            height: 24.sp,
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              color: const Color(0xFF565E6C),
            ),
          ),
        ),
      );
    }

    if (_hasError || _imageBytes == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: const Color(0xFFDEE1E6),
        child: Icon(
          Icons.broken_image,
          color: const Color(0xFF565E6C),
          size: 32.sp,
        ),
      );
    }

    return Image.memory(
      _imageBytes!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: widget.width,
          height: widget.height,
          color: const Color(0xFFDEE1E6),
          child: Icon(
            Icons.broken_image,
            color: const Color(0xFF565E6C),
            size: 32.sp,
          ),
        );
      },
    );
  }
}
