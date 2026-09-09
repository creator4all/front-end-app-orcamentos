import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_info_dialog.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/drive_item.dart';
import '../stores/file_opener_store.dart';
import 'file_details_modal.dart';

typedef DriveItemOpenCallback = FutureOr<void> Function(DriveItem item);

class DriveItemDetails {
  const DriveItemDetails._();

  static Future<void> show({
    required BuildContext context,
    required DriveItem item,
    required FileOpenerStore fileOpenerStore,
    required DriveItemOpenCallback onOpen,
  }) {
    return FileDetailsModal.show(
      context: context,
      item: item,
      fileOpenerStore: fileOpenerStore,
      onOpen: () async => onOpen(item),
      onDownload: () => _download(
        context: context,
        item: item,
        fileOpenerStore: fileOpenerStore,
      ),
      onShare: (sharePositionOrigin) => _share(
        context: context,
        item: item,
        fileOpenerStore: fileOpenerStore,
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  static Future<void> _download({
    required BuildContext context,
    required DriveItem item,
    required FileOpenerStore fileOpenerStore,
  }) async {
    final savedPath = await fileOpenerStore.downloadFile(item);
    if (!context.mounted) return;

    if (savedPath != null) {
      final fileName = savedPath.split('/').last;
      final messageStr = Platform.isIOS
          ? 'O arquivo "$fileName" foi disponibilizado nos seus Arquivos'
          : 'O arquivo "$fileName" foi salvo em: Downloads';

      CustomInfoDialog.show(
        context: context,
        type: DialogType.success,
        title: 'Download concluido',
        message: messageStr,
      );
      return;
    }

    final error = fileOpenerStore.errorMessage;
    if (error != null && error.isNotEmpty) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.error,
        title: 'Erro no download',
        message: error,
      );
      fileOpenerStore.clearError();
    }
  }

  static Future<void> _share({
    required BuildContext context,
    required DriveItem item,
    required FileOpenerStore fileOpenerStore,
    required Rect sharePositionOrigin,
  }) async {
    final savedPath = await fileOpenerStore.downloadFileToCache(item);
    if (!context.mounted) return;

    if (savedPath != null) {
      try {
        await Share.shareXFiles(
          [XFile(savedPath)],
          subject: item.name,
          sharePositionOrigin: sharePositionOrigin,
        );
      } catch (_) {
        if (!context.mounted) return;
        CustomInfoDialog.show(
          context: context,
          type: DialogType.error,
          title: 'Erro ao compartilhar',
          message: 'Não foi possível compartilhar o arquivo. Tente novamente.',
        );
      }
      return;
    }

    final error = fileOpenerStore.errorMessage;
    if (error != null && error.isNotEmpty) {
      CustomInfoDialog.show(
        context: context,
        type: DialogType.error,
        title: 'Erro ao compartilhar',
        message: error,
      );
      fileOpenerStore.clearError();
    }
  }
}
