import 'package:mobx/mobx.dart';

import '../../domain/models/file_model.dart';

part 'drive_store.g.dart';

class DriveStore = _DriveStore with _$DriveStore;

abstract class _DriveStore with Store {
  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  ObservableList<FileModel> files = ObservableList<FileModel>();

  @action
  Future<void> loadFiles() async {
    isLoading = true;
    error = null;
    try {
      // Simular carregamento de dados mockados
      await Future.delayed(const Duration(seconds: 1));

      files.clear();
      files.addAll(_getMockFiles());
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  void openFile(FileModel file) {
    if (file.isFolder) {
      openFolder(file);
    } else {
      // Simular abertura do arquivo
      print('Abrindo arquivo: ${file.name}');
      // Aqui seria a lógica para abrir o arquivo
    }
  }

  @action
  void openFolder(FileModel folder) {
    // Simular abertura da pasta
    print('Abrindo pasta: ${folder.name} (${folder.itemCount} itens)');
    // Aqui seria a lógica para navegar para dentro da pasta
  }

  @action
  void downloadFile(FileModel file) {
    // Simular download do arquivo
    print('Baixando arquivo: ${file.name}');
    // Aqui seria a lógica para download
  }

  List<FileModel> _getMockFiles() {
    return [
      FileModel(
        id: 'folder1',
        name: 'Documentos Financeiros',
        type: FileType.folder,
        sharedDate: DateTime.now().subtract(const Duration(days: 1)),
        sharedBy: 'João Silva',
        itemCount: 5,
      ),
      FileModel(
        id: 'folder2',
        name: 'Apresentações 2024',
        type: FileType.folder,
        sharedDate: DateTime.now().subtract(const Duration(days: 2)),
        sharedBy: 'Maria Santos',
        itemCount: 12,
      ),
      FileModel(
        id: 'folder3',
        name: 'Mídias do Produto',
        type: FileType.folder,
        sharedDate: DateTime.now().subtract(const Duration(days: 3)),
        sharedBy: 'Carlos Oliveira',
        itemCount: 8,
      ),
      FileModel(
        id: '1',
        name: 'Relatório Financeiro Q4',
        type: FileType.pdf,
        sharedDate: DateTime.now().subtract(const Duration(days: 1)),
        sharedBy: 'João Silva',
      ),
      FileModel(
        id: '2',
        name: 'Apresentação Produto',
        type: FileType.pptx,
        sharedDate: DateTime.now().subtract(const Duration(days: 2)),
        sharedBy: 'Maria Santos',
      ),
      FileModel(
        id: '3',
        name: 'Planilha Orçamentos',
        type: FileType.xlsx,
        sharedDate: DateTime.now().subtract(const Duration(days: 3)),
        sharedBy: 'Carlos Oliveira',
      ),
      FileModel(
        id: '4',
        name: 'Vídeo Demonstração',
        type: FileType.mp4,
        sharedDate: DateTime.now().subtract(const Duration(days: 4)),
        sharedBy: 'Ana Costa',
        thumbnailUrl:
            'https://via.placeholder.com/150x100/FF0000/FFFFFF?text=Video',
      ),
      FileModel(
        id: '5',
        name: 'Imagem Produto',
        type: FileType.jpg,
        sharedDate: DateTime.now().subtract(const Duration(days: 5)),
        sharedBy: 'Pedro Lima',
        thumbnailUrl:
            'https://via.placeholder.com/150x100/00FF00/FFFFFF?text=Image',
      ),
      FileModel(
        id: '6',
        name: 'Documento Contrato',
        type: FileType.docx,
        sharedDate: DateTime.now().subtract(const Duration(days: 6)),
        sharedBy: 'Luiza Ferreira',
      ),
    ];
  }
}
