import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_modal.dart';
import 'package:multimidiaapp/app/shared/widgets/user_avatar_widget.dart';

import '../../domain/entities/drive_item.dart';
import '../stores/file_opener_store.dart';
import '../stores/new_drive_store.dart';

class FileDetailsModal {
  static Future<void> show({
    required BuildContext context,
    required DriveItem item,
    required FileOpenerStore fileOpenerStore,
    required Future<void> Function() onOpen,
    required Future<void> Function() onDownload,
    required Future<void> Function(Rect sharePositionOrigin) onShare,
  }) {
    return CustomModal.show(
      context: context,
      title: 'Detalhes do arquivo',
      content: _FileDetailsContent(
        item: item,
        fileOpenerStore: fileOpenerStore,
        onOpen: onOpen,
        onDownload: onDownload,
        onShare: onShare,
      ),
    );
  }
}

class _FileDetailsContent extends StatefulWidget {
  final DriveItem item;
  final FileOpenerStore fileOpenerStore;
  final Future<void> Function() onOpen;
  final Future<void> Function() onDownload;
  final Future<void> Function(Rect sharePositionOrigin) onShare;

  const _FileDetailsContent({
    required this.item,
    required this.fileOpenerStore,
    required this.onOpen,
    required this.onDownload,
    required this.onShare,
  });

  @override
  State<_FileDetailsContent> createState() => _FileDetailsContentState();
}

class _FileDetailsContentState extends State<_FileDetailsContent> {
  bool _isOpening = false;
  bool _isLoadingDetails = true;
  bool _isSharing = false;
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
    if (_isOpening || _isSharing || widget.fileOpenerStore.isDownloading) {
      return;
    }
    setState(() => _isOpening = true);
    try {
      await widget.onOpen();
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }

  Future<void> _handleDownload() async {
    if (_isOpening || _isSharing || widget.fileOpenerStore.isDownloading) {
      return;
    }
    await widget.onDownload();
  }

  void _handleCancelDownload() {
    widget.fileOpenerStore.cancelDownload();
  }

  Future<void> _handleShare(BuildContext shareContext) async {
    if (_isOpening || _isSharing || widget.fileOpenerStore.isDownloading) {
      return;
    }

    final renderObject = shareContext.findRenderObject();
    final screenSize = MediaQuery.sizeOf(context);
    final sharePositionOrigin = renderObject is RenderBox &&
            renderObject.hasSize &&
            !renderObject.size.isEmpty
        ? renderObject.localToGlobal(Offset.zero) & renderObject.size
        : Rect.fromCenter(
            center: Offset(screenSize.width / 2, screenSize.height / 2),
            width: 1,
            height: 1,
          );

    setState(() => _isSharing = true);
    try {
      await widget.onShare(sharePositionOrigin);
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _detailedItem ?? widget.item;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        Observer(
          builder: (_) {
            final isOpeningActive = widget.fileOpenerStore.isOperationActive(
              item,
              FileOperation.open,
            );
            final isBusy = widget.fileOpenerStore.isDownloading;

            return _buildActionButton(
              icon: item.type == DriveItemType.folder
                  ? Icons.folder_open
                  : Icons.open_in_new,
              label: item.type == DriveItemType.folder
                  ? 'Abrir'
                  : 'Abrir/Visualizar',
              isLoading: _isOpening || isOpeningActive,
              isDisabled: _isSharing || (isBusy && !isOpeningActive),
              onTap: _handleOpen,
            );
          },
        ),
        if (item.type != DriveItemType.folder) ...[
          SizedBox(height: 12.h),
          _buildDownloadButton(item),
        ],
        if (item.type != DriveItemType.folder) ...[
          SizedBox(
            height: 12.h,
          ),
          Observer(
            builder: (_) {
              final isSharingActive = widget.fileOpenerStore.isOperationActive(
                item,
                FileOperation.share,
              );
              final isBusy = widget.fileOpenerStore.isDownloading;

              return Builder(
                builder: (shareContext) => _buildActionButton(
                  icon: Icons.share_outlined,
                  label: 'Compartilhar',
                  isLoading: _isSharing || isSharingActive,
                  isDisabled: _isOpening || (isBusy && !isSharingActive),
                  onTap: () => _handleShare(shareContext),
                ),
              );
            },
          ),
        ],
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isLoading,
    bool isDisabled = false,
    required VoidCallback onTap,
  }) {
    final foregroundColor = isDisabled && !isLoading
        ? const Color(0xFF9095A0)
        : const Color(0xFF171A1F);
    final borderColor = isDisabled && !isLoading
        ? const Color(0xFFE5E7EB)
        : const Color(0xFFBCC1CA);

    return InkWell(
      onTap: isLoading || isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: borderColor,
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
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            else
              Icon(
                icon,
                size: 20.sp,
                color: foregroundColor,
              ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton(DriveItem item) {
    return Observer(
      builder: (_) {
        final isDirectDownloadActive = widget.fileOpenerStore
            .isOperationActive(item, FileOperation.download);
        final isBusy = widget.fileOpenerStore.isDownloading;

        final label = isDirectDownloadActive
            ? 'Cancelar ${widget.fileOpenerStore.progressPercentage}%'
            : 'Baixar';
        final icon = isDirectDownloadActive
            ? Icons.cancel_outlined
            : Icons.download_outlined;

        return InkWell(
          onTap: isDirectDownloadActive
              ? _handleCancelDownload
              : (isBusy || _isOpening || _isSharing ? null : _handleDownload),
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
      },
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
