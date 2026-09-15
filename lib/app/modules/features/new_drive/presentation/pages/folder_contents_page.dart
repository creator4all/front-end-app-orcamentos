import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_top_bar.dart';

import '../../../auth/presentation/stores/auth_store.dart';
import '../../domain/entities/drive_item.dart';
import '../stores/file_opener_store.dart';
import '../stores/new_drive_store.dart';
import '../widgets/drive_item_details.dart';
import '../widgets/item_card_doc.dart';

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

  bool _isLeaving = false;

  @override
  void initState() {
    super.initState();
    store.navigateToFolder(widget.folderId, widget.folderName ?? 'Pasta');
    _loadFolder();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFolder({bool forceRefresh = false}) async {
    if (forceRefresh || store.getFolderFromCache(widget.folderId) == null) {
      await store.loadFolderContents(widget.folderId);
    }
  }

  List<DriveItem> _filteredChildren(DriveItem folder) {
    final children = folder.children ?? [];
    if (store.searchQuery.isEmpty) return children;

    final query = store.searchQuery.toLowerCase();
    return children
        .where((item) => item.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // O breadcrumb já escolheu o destino antes de remover suas páginas.
        if (didPop && store.activeFolderId == widget.folderId) {
          store.navigateBack();
          _syncFolderRouteArguments();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: CustomTopBar(
          title: widget.folderName ?? 'Pasta',
          showBackButton: true,
          onBackPressed: _goBack,
          authStore: _authStore,
        ),
        body: Observer(builder: (_) => _buildBody()),
      ),
    );
  }

  void _goBack() {
    if (_isLeaving || !mounted) return;
    _isLeaving = true;
    Modular.to.pop();
  }

  void _navigateToAncestor(int index) {
    if (_isLeaving || !mounted) return;
    final pops = store.folderStack.length - 1 - index;
    if (pops <= 0) return;

    _isLeaving = true;
    store.navigateToStackIndex(index);
    _syncFolderRouteArguments();
    if (index == -1) {
      Modular.to.popUntil(ModalRoute.withName('/drive/'));
    } else {
      for (var i = 0; i < pops; i++) {
        Modular.to.pop();
      }
    }
  }

  void _syncFolderRouteArguments() {
    final target = store.folderStack.isEmpty ? null : store.folderStack.last;
    // Modular 5 mantém args globais após pop. Seu setArguments ignora o dado
    // recebido; usamos o setter do parser já instalado, sem recriar rotas.
    Modular.routerDelegate.parser.setArguments(Modular.args.copyWith(data: {
      if (target != null) 'folderId': target.id,
      if (target != null) 'folderName': target.name,
    }));
  }

  Widget _buildBody() {
    if (store.activeFolderId == widget.folderId && store.isLoadingFolder) {
      return const Center(child: CircularProgressIndicator());
    }

    final folder = store.getFolderFromCache(widget.folderId);

    if (folder == null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadFolder(forceRefresh: true),
      child: Observer(
        builder: (_) {
          // Observer necessário para reagir a mudanças no searchQuery
          final items = _filteredChildren(folder);

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: [
              _buildBreadcrumb(),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 16.h,
                ),
                child: _buildSearchField(),
              ),
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
              if (items.isEmpty && (folder.children?.isEmpty ?? true))
                _buildEmptyState()
              else
                ...items.map((item) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Column(
                        children: [
                          ItemCardDoc(
                            item: item,
                            onTap: () => _handleItemTap(item),
                          ),
                          SizedBox(height: 12.h),
                        ],
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBreadcrumb() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 12.h,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _navigateToAncestor(-1),
              child: Text(
                'Drive',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF565E6C),
                ),
              ),
            ),
            Observer(
              builder: (_) {
                return Row(
                  children: store.folderStack.asMap().entries.map((entry) {
                    final index = entry.key;
                    final breadcrumb = entry.value;
                    final isLast = index == store.folderStack.length - 1;

                    return Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Icon(
                            Icons.chevron_right,
                            size: 16.sp,
                            color: const Color(0xFF565E6C),
                          ),
                        ),
                        GestureDetector(
                          onTap:
                              isLast ? null : () => _navigateToAncestor(index),
                          child: Text(
                            breadcrumb.name,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isLast
                                  ? const Color(0xFF171A1F)
                                  : const Color(0xFF565E6C),
                              fontWeight:
                                  isLast ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

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
          if (store.errorMessage?.isNotEmpty ?? false) ...[
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
            onPressed: _goBack,
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }

  void _handleItemTap(DriveItem item) {
    DriveItemDetails.show(
      context: context,
      item: item,
      fileOpenerStore: fileOpenerStore,
      onOpen: _openFileFromDetails,
    );
  }

  Future<void> _openFileFromDetails(DriveItem item) async {
    if (item.type == DriveItemType.folder) {
      Modular.to.pushNamed(
        './folder',
        arguments: {
          'folderId': item.id,
          'folderName': item.name,
        },
      );
      return;
    }

    if (item.type == DriveItemType.video) {
      Modular.to.pushNamed(
        './video-player',
        arguments: item,
      );
      return;
    }

    if (item.type == DriveItemType.image) {
      Modular.to.pushNamed(
        './image-viewer',
        arguments: item,
      );
      return;
    }

    await fileOpenerStore.openFile(item);
  }
}
