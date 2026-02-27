import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../../../config/api_config.dart';
import '../../domain/entities/drive_item.dart';

class ImageViewerPage extends StatefulWidget {
  final DriveItem item;

  const ImageViewerPage({
    super.key,
    required this.item,
  });

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _token;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await _secureStorage.read(key: 'auth_token');
    setState(() {
      _token = token;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = '${ApiConfig.baseUrl}/api/files/${widget.item.id}/view';

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2830F2),
          ),
        ),
      );
    }

    if (_token == null || _token!.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Erro: Token não encontrado',
            style: TextStyle(color: Colors.white, fontSize: 16.sp),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.item.name,
          style: TextStyle(fontSize: 16.sp),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PhotoView(
        imageProvider: NetworkImage(
          imageUrl,
          headers: {
            'Authorization': 'Bearer $_token',
          },
        ),
        loadingBuilder: (context, event) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  value: event == null
                      ? 0
                      : event.cumulativeBytesLoaded /
                          (event.expectedTotalBytes ?? 1),
                  color: const Color(0xFF2830F2),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Carregando imagem...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64.sp,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Erro ao carregar imagem',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  error.toString(),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 4,
        initialScale: PhotoViewComputedScale.contained,
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
      ),
    );
  }
}
