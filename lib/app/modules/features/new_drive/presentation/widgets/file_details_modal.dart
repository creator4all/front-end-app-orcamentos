import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_modal.dart';
import 'package:multimidiaapp/app/shared/widgets/user_avatar_widget.dart';

import '../../domain/entities/drive_item.dart';
import '../stores/new_drive_store.dart';

/// Modal de detalhes do arquivo
/// Carrega detalhes da API ao abrir para obter sharedBy e downloadUrl
class FileDetailsModal {
  /// Exibe o modal de detalhes do arquivo
  static Future<void> show({
    required BuildContext context,
    required DriveItem item,
    required Future<void> Function() onOpen,
    required Future<void> Function() onDownload,
  }) {
    return CustomModal.show(
      context: context,
      title: 'Detalhes do arquivo',
      content: _FileDetailsContent(
        item: item,
        onOpen: onOpen,
        onDownload: onDownload,
      ),
    );
  }
}

class _FileDetailsContent extends StatefulWidget {
  final DriveItem item;
  final Future<void> Function() onOpen;
  final Future<void> Function() onDownload;

  const _FileDetailsContent({
    required this.item,
    required this.onOpen,
    required this.onDownload,
  });

  @override
  State<_FileDetailsContent> createState() => _FileDetailsContentState();
}

class _FileDetailsContentState extends State<_FileDetailsContent> {
  bool _isOpening = false;
  bool _isDownloading = false;
  bool _isLoadingDetails = true;
  DriveItem? _detailedItem;

  @override
  void initState() {
    super.initState();
    _loadFileDetails();
  }

  Future<void> _loadFileDetails() async {
    try {
      final store = Modular.get<NewDriveStore>();
      final details = await store.getFileDetails(widget.item.id);
      if (mounted) {
        setState(() {
          _detailedItem = details;
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDetails = false;
        });
      }
    }
  }

  Future<void> _handleOpen() async {
    if (_isOpening || _isDownloading) return;
    setState(() => _isOpening = true);
    try {
      await widget.onOpen();
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }

  Future<void> _handleDownload() async {
    if (_isOpening || _isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      await widget.onDownload();
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usar item detalhado se disponível, senão usar item original
    final item = _detailedItem ?? widget.item;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ícone do tipo de arquivo
        Container(
          width: 64.w,
          height: 64.h,
          decoration: BoxDecoration(
            color: _getColorForType(item.type),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getIconForType(item.type),
            color: Colors.white,
            size: 32.sp,
          ),
        ),
        SizedBox(height: 16.h),

        // Nome completo do arquivo
        Text(
          item.name,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF171A1F),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),

        // Tamanho do arquivo
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storage_outlined,
              size: 18.sp,
              color: const Color(0xFF565E6C),
            ),
            SizedBox(width: 8.w),
            Text(
              'Tamanho: ${item.size}',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF565E6C),
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),

        // Seção "Compartilhado por" - com loading
        if (_isLoadingDetails) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Compartilhado por:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF171A1F),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            child: Center(
              child: SizedBox(
                width: 24.sp,
                height: 24.sp,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF565E6C),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ] else if (item.sharedBy != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Compartilhado por:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF171A1F),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Card do usuário que compartilhou
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                UserAvatarWidget(
                  avatarBase64: item.sharedBy!.avatarUrl,
                  userName: item.sharedBy!.name,
                  radius: 20,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.sharedBy!.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF171A1F),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        item.sharedBy!.email,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF565E6C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
        ],

        // Botões de ação
        _buildActionButton(
          icon: Icons.open_in_new,
          label: 'Abrir/Visualizar',
          isLoading: _isOpening,
          onTap: _handleOpen,
        ),
        SizedBox(height: 12.h),
        _buildActionButton(
          icon: Icons.download_outlined,
          label: 'Baixar',
          isLoading: _isDownloading,
          onTap: _handleDownload,
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFBCC1CA),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 20.sp,
                height: 20.sp,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF171A1F),
                ),
              )
            else
              Icon(
                icon,
                size: 20.sp,
                color: const Color(0xFF171A1F),
              ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF171A1F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(DriveItemType type) {
    switch (type) {
      case DriveItemType.document:
        return Icons.description;
      case DriveItemType.video:
        return Icons.play_circle_outline;
      case DriveItemType.image:
        return Icons.image;
      case DriveItemType.folder:
        return Icons.folder;
    }
  }

  Color _getColorForType(DriveItemType type) {
    switch (type) {
      case DriveItemType.document:
        return const Color(0xFF2830F2);
      case DriveItemType.video:
        return const Color(0xFF800019);
      case DriveItemType.image:
        return const Color(0xFF103323);
      case DriveItemType.folder:
        return const Color(0xFF402F00);
    }
  }
}
