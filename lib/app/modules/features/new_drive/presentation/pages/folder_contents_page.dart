import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_top_bar.dart';

import '../../../auth/presentation/stores/auth_store.dart';
import '../../domain/entities/drive_item.dart';
import '../stores/file_opener_store.dart';
import '../stores/new_drive_store.dart';
import '../widgets/item_card_doc.dart';

/// Página para exibir conteúdo de uma pasta
///
/// Permite ao usuário:
/// - Ver todos os arquivos dentro de uma pasta específica
/// - Navegar com breadcrumb
/// - Abrir arquivos ou pastas aninhadas
class FolderContentsPage extends StatefulWidget {
  final String folderId;
  final String? folderName;

  const FolderContentsPage({
    super.key,
    required this.folderId,
    this.folderName,
  });

  @override
  State<FolderContentsPage> createState() => _FolderContentsPageState();
}

class _FolderContentsPageState extends State<FolderContentsPage> {
  final NewDriveStore store = Modular.get<NewDriveStore>();
  final FileOpenerStore fileOpenerStore = Modular.get<FileOpenerStore>();
  final AuthStore _authStore = Modular.get<AuthStore>();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Carregar conteúdo da pasta
    store.loadFolderContents(widget.folderId);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: CustomTopBar(
        title: widget.folderName ?? 'Pasta',
        showBackButton: true,
        authStore: _authStore,
      ),
      body: Observer(
        builder: (_) {
          if (store.isLoadingFolder) {
            return const Center(child: CircularProgressIndicator());
          }

          final folder = store.currentFolder;

          if (folder == null) {
            return _buildErrorState();
          }

          final items = folder.children ?? [];

          if (items.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Breadcrumb (opcional)
              _buildBreadcrumb(folder),

              // Barra de pesquisa
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 16.h,
                ),
                child: _buildSearchField(),
              ),

              // Texto informativo
              Padding(
                padding: EdgeInsets.only(
                  left: 10.w,
                  right: 10.w,
                  bottom: 12.h,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Conteúdo da pasta',
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
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  itemCount: items.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Column(
                      children: [
                        ItemCardDoc(
                          itemName: item.name,
                          itemSize: item.size,
                          itemDate: item.getFormattedDate(),
                          itemType: item.type,
                          thumbnailUrl: item.thumbnailUrl,
                          onTap: () => _handleItemTap(item),
                        ),
                        if (index < items.length - 1) SizedBox(height: 12.h),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Breadcrumb para mostrar caminho dentro de pastas
  Widget _buildBreadcrumb(DriveItem folder) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 12.h,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Drive
            Text(
              'Drive',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF565E6C),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Icon(
                Icons.chevron_right,
                size: 16.sp,
                color: const Color(0xFF565E6C),
              ),
            ),
            // Pasta atual
            Text(
              folder.name,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF171A1F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Campo de busca
  Widget _buildSearchField() {
    return Container(
      constraints: BoxConstraints(maxHeight: 50.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: searchController,
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

  /// Estado vazio
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64.sp,
            color: const Color(0xFF9CA3AF),
          ),
          SizedBox(height: 16.h),
          Text(
            'Pasta vazia',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF171A1F),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Nenhum arquivo nesta pasta',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF565E6C),
            ),
          ),
        ],
      ),
    );
  }

  /// Estado de erro
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: const Color(0xFFEF4444),
          ),
          SizedBox(height: 16.h),
          Text(
            'Erro ao carregar pasta',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF171A1F),
            ),
          ),
          if (store.errorMessage != null && store.errorMessage!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                store.errorMessage!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF565E6C),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => Modular.to.pop(),
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }

  /// Trata clique em item
  void _handleItemTap(DriveItem item) {
    if (item.type == DriveItemType.folder) {
      // Navegar para a pasta
      Modular.to.pushNamed(
        './folder',
        arguments: {
          'folderId': item.id,
          'folderName': item.name,
        },
      );
    } else if (item.type == DriveItemType.video) {
      // Navegar para video player
      Modular.to.pushNamed(
        './video-player',
        arguments: item,
      );
    } else if (item.type == DriveItemType.image) {
      // Navegar para image viewer
      Modular.to.pushNamed(
        './image-viewer',
        arguments: item,
      );
    } else {
      // Download e abrir arquivo (documento, etc)
      fileOpenerStore.openFile(item);
    }
  }
}
