import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

import '../../domain/entities/drive_item.dart';
import '../../domain/usecases/download_and_open_file_usecase.dart';
import '../../new_drive_failure.dart';

part 'file_opener_store.g.dart';

/// Store para gerenciar o estado de download e abertura de arquivos
///
/// Responsabilidades:
/// - Controlar estado de loading durante download
/// - Gerenciar progresso do download
/// - Tratar erros e exibir mensagens apropriadas
/// - Abrir arquivos após download
class FileOpenerStore = _FileOpenerStoreBase with _$FileOpenerStore;

abstract class _FileOpenerStoreBase with Store {
  final DownloadAndOpenFileUsecase downloadAndOpenFileUsecase;

  _FileOpenerStoreBase(this.downloadAndOpenFileUsecase);

  /// Indica se está fazendo download/processamento
  @observable
  bool isDownloading = false;

  /// Progresso do download (0.0 a 1.0)
  @observable
  double downloadProgress = 0.0;

  /// Mensagem de erro caso ocorra algum problema
  @observable
  String? errorMessage;

  /// Item atualmente sendo processado
  @observable
  DriveItem? currentItem;

  /// Caminho do último arquivo salvo
  @observable
  String? lastFilePath;

  /// Faz o download e abre o arquivo
  ///
  /// [item] - Item do drive a ser aberto
  @action
  Future<void> openFile(DriveItem item) async {
    try {
      // Limpar estado anterior
      errorMessage = null;
      currentItem = item;
      isDownloading = true;
      downloadProgress = 0.0;

      debugPrint('🚀 Iniciando abertura do arquivo: ${item.name}');

      // Executar usecase
      final result = await downloadAndOpenFileUsecase(
        item,
        onProgress: (progress) {
          setDownloadProgress(progress);
        },
      );

      // Processar resultado
      result.fold(
        (failure) {
          _handleFailure(failure);
        },
        (filePath) {
          lastFilePath = filePath;
          debugPrint('✅ Arquivo processado com sucesso: $filePath');
        },
      );
    } catch (e) {
      debugPrint('❌ Erro inesperado ao abrir arquivo: $e');
      errorMessage = 'Erro inesperado: $e';
    } finally {
      isDownloading = false;
      downloadProgress = 0.0;
      currentItem = null;
    }
  }

  /// Atualiza o progresso do download
  @action
  void setDownloadProgress(double progress) {
    downloadProgress = progress;
  }

  /// Limpa o estado de erro
  @action
  void clearError() {
    errorMessage = null;
  }

  /// Reseta todo o estado da store
  @action
  void reset() {
    isDownloading = false;
    downloadProgress = 0.0;
    errorMessage = null;
    currentItem = null;
    lastFilePath = null;
  }

  /// Trata falhas específicas com mensagens apropriadas
  void _handleFailure(NewDriveFailure failure) {
    if (failure is UnsupportedFileTypeFailure) {
      errorMessage = 'Este tipo de arquivo não é suportado';
    } else if (failure is NoAppToOpenFailure) {
      errorMessage = 'Nenhum aplicativo disponível para abrir este arquivo.\n'
          'Por favor, instale um aplicativo compatível.';
    } else if (failure is PermissionDeniedFailure) {
      errorMessage = 'Permissão negada para acessar o arquivo.\n'
          'Verifique as permissões do aplicativo.';
    } else if (failure is FileNotFoundFailure) {
      errorMessage = 'Arquivo não encontrado após download.\n'
          'Tente novamente.';
    } else if (failure is DownloadFileFailure) {
      errorMessage = 'Erro ao fazer download do arquivo.\n'
          'Verifique sua conexão e tente novamente.';
    } else if (failure is ConnectionFailure) {
      errorMessage = 'Erro de conexão.\n'
          'Verifique sua internet e tente novamente.';
    } else {
      errorMessage = 'Erro ao processar arquivo: ${failure.message}';
    }

    debugPrint('❌ Falha: $errorMessage');
  }

  /// Computa se há algum erro
  @computed
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// Computa a porcentagem do progresso
  @computed
  int get progressPercentage => (downloadProgress * 100).toInt();
}
