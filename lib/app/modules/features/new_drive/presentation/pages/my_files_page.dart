import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_top_bar.dart';

import '../../../../features/auth/presentation/stores/auth_store.dart';
import '../../domain/entities/drive_item.dart';
import '../stores/file_opener_store.dart';
import '../stores/new_drive_store.dart';
import '../widgets/drive_item_list_view.dart';
import '../widgets/file_details_modal.dart';

/// Página de meus arquivos
///
/// Exibe todos os arquivos enviados pelo usuário (apenas administradores)
/// Layout idêntico ao CategoryDetailsPage
class MyFilesPage extends StatefulWidget {
  const MyFilesPage({super.key});

  @override
  State<MyFilesPage> createState() => _MyFilesPageState();
}

class _MyFilesPageState extends State<MyFilesPage> {
  final NewDriveStore store = Modular.get<NewDriveStore>();
  final FileOpenerStore fileOpenerStore = Modular.get<FileOpenerStore>();
  final AuthStore authStore = Modular.get<AuthStore>();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Verificar se é administrador
    if (!authStore.isAdmin) {
      // Voltar se não for admin
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          Modular.to.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Você não tem permissão para acessar esta página'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
      return;
    }

    // Definir modo de visualização
    store.setViewMode('my-files');
  }

  @override
  void dispose() {
    // Limpar seleção ao sair da página
    store.clearViewMode();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: CustomTopBar(
        title: 'Meus Arquivos',
        showBackButton: true,
        authStore: authStore,
      ),
      body: Observer(
        builder: (_) {
          final items = store.filteredViewItems;

          if (items.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Barra de pesquisa
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 16.h,
                ),
                child: _buildSearchField(),
              ),

              // Texto "Arquivos que você enviou"
              Padding(
                padding: EdgeInsets.only(
                  left: 10.w,
                  right: 10.w,
                  bottom: 12.h,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Arquivos que você enviou',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF565E6C),
                    ),
                  ),
                ),
              ),

              // ListView dos itens
              Expanded(
                child: DriveItemListView(
                  items: items,
                  onItemTap: _showFileDetails,
                  showMenu: false,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Campo de pesquisa de arquivos
  Widget _buildSearchField() {
    return Container(
      constraints: BoxConstraints(maxHeight: 50.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) => store.setSearchQuery(value),
        decoration: InputDecoration(
          hintText: 'Buscar arquivo',
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF565E6C),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: const Color(0xFF565E6C),
            size: 20.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF171A1F),
        ),
      ),
    );
  }

  /// Widget de estado vazio
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64.sp,
            color: const Color(0xFFDEE1E6),
          ),
          SizedBox(height: 16.h),
          Text(
            'Nenhum arquivo encontrado',
            style: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFF565E6C),
            ),
          ),
        ],
      ),
    );
  }

  /// Exibe modal de detalhes do arquivo
  void _showFileDetails(DriveItem item) {
    FileDetailsModal.show(
      context: context,
      item: item,
      onOpen: () async => _handleFileOpen(item),
      onDownload: () async => _handleDownload(item),
    );
  }

  /// Realiza download do arquivo
  Future<void> _handleDownload(DriveItem item) async {
    await fileOpenerStore.openFile(item);
  }

  /// Abre o arquivo ou navega para pasta/vídeo/imagem
  void _handleFileOpen(DriveItem item) {
    if (item.type == DriveItemType.folder) {
      // Navegar para a pasta
      Modular.to.pushNamed(
        '/drive/folder',
        arguments: {
          'folderId': item.id,
          'folderName': item.name,
        },
      );
    } else if (item.type == DriveItemType.video) {
      // Navegar para video player
      Modular.to.pushNamed(
        '/drive/video-player',
        arguments: item,
      );
    } else if (item.type == DriveItemType.image) {
      // Navegar para image viewer
      Modular.to.pushNamed(
        '/drive/image-viewer',
        arguments: item,
      );
    } else {
      // Download e abrir arquivo (documento, etc)
      fileOpenerStore.openFile(item);
    }
  }
}
