import 'package:mobx/mobx.dart';

import '../../domain/entities/drive_item.dart';
import '../../domain/usecases/download_and_open_file_usecase.dart';
import '../../domain/usecases/download_file_to_cache_usecase.dart';
import '../../domain/usecases/download_file_usecase.dart';
import '../../new_drive_failure.dart';

part 'file_opener_store.g.dart';

class FileOpenerStore = _FileOpenerStoreBase with _$FileOpenerStore;

enum FileOperation {
  open,
  download,
  share,
}

abstract class _FileOpenerStoreBase with Store {
  final DownloadAndOpenFileUsecase downloadAndOpenFileUsecase;
  final DownloadFileUsecase downloadFileUsecase;
  final DownloadFileToCacheUsecase downloadFileToCacheUsecase;

  _FileOpenerStoreBase(
    this.downloadAndOpenFileUsecase,
    this.downloadFileUsecase,
    this.downloadFileToCacheUsecase,
  );

  @observable
  bool isDownloading = false;

  @observable
  bool isDirectDownload = false;

  @observable
  double downloadProgress = 0.0;

  @observable
  String? errorMessage;

  @observable
  DriveItem? currentItem;

  @observable
  String? lastFilePath;

  @observable
  FileOperation? currentOperation;

  @action
  Future<void> openFile(DriveItem item) async {
    if (isDownloading) return;

    try {
      _startOperation(item, FileOperation.open);

      final result = await downloadAndOpenFileUsecase(
        item,
        onProgress: (progress) {
          setDownloadProgress(progress);
        },
      );

      result.fold(
        (failure) {
          runInAction(() => _handleFailure(failure));
        },
        (filePath) {
          runInAction(() => lastFilePath = filePath);
        },
      );
    } catch (e) {
      runInAction(() => errorMessage = 'Erro inesperado: $e');
    } finally {
      runInAction(() {
        isDownloading = false;
        isDirectDownload = false;
        downloadProgress = 0.0;
        currentItem = null;
        currentOperation = null;
      });
    }
  }

  Future<String?> downloadFile(DriveItem item) async {
    if (isDownloading) return null;

    try {
      runInAction(() {
        _startOperation(item, FileOperation.download);
      });

      final result = await downloadFileUsecase(
        item,
        onProgress: (progress) {
          setDownloadProgress(progress);
        },
      );

      return result.fold(
        (failure) {
          _handleFailure(failure);
          return null;
        },
        (filePath) {
          runInAction(() {
            lastFilePath = filePath;
          });
          return filePath;
        },
      );
    } catch (e) {
      runInAction(() {
        errorMessage = 'Erro inesperado: $e';
      });
      return null;
    } finally {
      runInAction(() {
        isDownloading = false;
        isDirectDownload = false;
        downloadProgress = 0.0;
        currentItem = null;
        currentOperation = null;
      });
    }
  }

  Future<String?> downloadFileToCache(DriveItem item) async {
    if (isDownloading) return null;

    try {
      runInAction(() {
        _startOperation(item, FileOperation.share);
      });

      final result = await downloadFileToCacheUsecase(
        item,
        onProgress: (progress) {
          setDownloadProgress(progress);
        },
      );

      return result.fold(
        (failure) {
          _handleFailure(failure);
          return null;
        },
        (filePath) {
          runInAction(() {
            lastFilePath = filePath;
          });
          return filePath;
        },
      );
    } catch (e) {
      runInAction(() {
        errorMessage = 'Erro inesperado: $e';
      });
      return null;
    } finally {
      runInAction(() {
        isDownloading = false;
        isDirectDownload = false;
        downloadProgress = 0.0;
        currentItem = null;
        currentOperation = null;
      });
    }
  }

  @action
  void cancelDownload() {
    downloadFileUsecase.cancelCurrentDownload();
  }

  @action
  void setDownloadProgress(double progress) {
    downloadProgress = progress;
  }

  @action
  void clearError() {
    errorMessage = null;
  }

  @action
  void reset() {
    isDownloading = false;
    isDirectDownload = false;
    downloadProgress = 0.0;
    errorMessage = null;
    currentItem = null;
    currentOperation = null;
    lastFilePath = null;
  }

  void _startOperation(DriveItem item, FileOperation operation) {
    errorMessage = null;
    currentItem = item;
    currentOperation = operation;
    isDownloading = true;
    isDirectDownload = operation == FileOperation.download;
    downloadProgress = 0.0;
  }

  bool isOperationActive(DriveItem item, FileOperation operation) {
    return isDownloading &&
        currentOperation == operation &&
        currentItem?.id == item.id;
  }

  void _handleFailure(NewDriveFailure failure) {
    if (failure is NoAppToOpenFailure) {
      errorMessage = 'Nenhum aplicativo disponível para abrir este arquivo.\n'
          'Por favor, instale um aplicativo compatível.';
    } else if (failure is PermissionDeniedFailure) {
      errorMessage = 'Permissão negada para acessar o arquivo.\n'
          'Verifique as permissões do aplicativo.';
    } else if (failure is FileNotFoundFailure) {
      errorMessage = 'Arquivo não encontrado após download.\n'
          'Tente novamente.';
    } else if (failure is DownloadCancelledFailure) {
      return;
    } else if (failure is DownloadFileFailure) {
      errorMessage = _friendlyDownloadMessage(failure.message);
    } else if (failure is ConnectionFailure) {
      errorMessage = 'Erro de conexão.\n'
          'Verifique sua internet e tente novamente.';
    } else {
      errorMessage = 'Erro ao processar arquivo: ${failure.message}';
    }
  }

  String _friendlyDownloadMessage(String raw) {
    final lower = raw.toLowerCase();

    final isTimeout = lower.contains('tempo de requisição esgotado') ||
        lower.contains('timeout') ||
        lower.contains('[408]');
    if (isTimeout) {
      return 'Tempo esgotado ao baixar o arquivo.\n'
          'Verifique sua conexão e tente novamente.';
    }

    final isConnection = lower.contains('conexão') ||
        lower.contains('internet') ||
        lower.contains('socket');
    if (isConnection) {
      return 'Erro de conexão.\n'
          'Verifique sua internet e tente novamente.';
    }

    return 'Não foi possível baixar o arquivo.\nTente novamente.';
  }

  @computed
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  @computed
  int get progressPercentage => (downloadProgress * 100).toInt();
}
