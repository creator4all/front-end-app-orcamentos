import 'package:mobx/mobx.dart';

import '../../domain/entities/drive_item.dart';
import '../../domain/usecases/download_file_usecase.dart';
import '../../domain/usecases/download_and_open_file_usecase.dart';
import '../../new_drive_failure.dart';

part 'file_opener_store.g.dart';

class FileOpenerStore = _FileOpenerStoreBase with _$FileOpenerStore;

abstract class _FileOpenerStoreBase with Store {
  final DownloadAndOpenFileUsecase downloadAndOpenFileUsecase;
  final DownloadFileUsecase downloadFileUsecase;

  _FileOpenerStoreBase(
    this.downloadAndOpenFileUsecase,
    this.downloadFileUsecase,
  );

  @observable
  bool isDownloading = false;

  @observable
  double downloadProgress = 0.0;

  @observable
  String? errorMessage;

  @observable
  DriveItem? currentItem;

  @observable
  String? lastFilePath;

  @action
  Future<void> openFile(DriveItem item) async {
    try {
      errorMessage = null;
      currentItem = item;
      isDownloading = true;
      downloadProgress = 0.0;

      final result = await downloadAndOpenFileUsecase(
        item,
        onProgress: (progress) {
          setDownloadProgress(progress);
        },
      );

      result.fold(
        (failure) {
          _handleFailure(failure);
        },
        (filePath) {
          lastFilePath = filePath;
        },
      );
    } catch (e) {
      errorMessage = 'Erro inesperado: $e';
    } finally {
      isDownloading = false;
      downloadProgress = 0.0;
      currentItem = null;
    }
  }

  Future<String?> downloadFile(DriveItem item) async {
    try {
      runInAction(() {
        errorMessage = null;
        currentItem = item;
        isDownloading = true;
        downloadProgress = 0.0;
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
        downloadProgress = 0.0;
        currentItem = null;
      });
    }
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
    downloadProgress = 0.0;
    errorMessage = null;
    currentItem = null;
    lastFilePath = null;
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
    } else if (failure is DownloadFileFailure) {
      errorMessage = failure.message;
    } else if (failure is ConnectionFailure) {
      errorMessage = 'Erro de conexão.\n'
          'Verifique sua internet e tente novamente.';
    } else {
      errorMessage = 'Erro ao processar arquivo: ${failure.message}';
    }
  }

  @computed
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  @computed
  int get progressPercentage => (downloadProgress * 100).toInt();
}
