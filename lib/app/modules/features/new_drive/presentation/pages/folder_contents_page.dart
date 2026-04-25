import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_info_dialog.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_top_bar.dart';

import '../../../auth/presentation/stores/auth_store.dart';
import '../../domain/entities/drive_item.dart';
import '../stores/file_opener_store.dart';
import '../stores/new_drive_store.dart';
import '../widgets/item_card_doc.dart';
import '../widgets/file_details_modal.dart';

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

  DriveItem? _localFolder;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    store.setSearchQuery('');
    _loadFolder();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFolder({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Tentar restaurar do cache para evitar chamada desnecessária à API
    if (!forceRefresh) {
      final cached = store.getFolderFromCache(widget.folderId);
      if (cached != null) {
        setState(() {
          _localFolder = cached;
          _isLoading = false;
        });
        return;
      }
    }

    await store.loadFolderContents(widget.folderId);

    if (!mounted) return;

    final loaded = store.getFolderFromCache(widget.folderId);
    setState(() {
      _localFolder = loaded;
      _isLoading = false;
      _errorMessage = loaded == null ? store.errorMessage : null;
    });
  }

  /// Filtra children da pasta local usando o searchQuery do store.
  List<DriveItem> get _filteredChildren {
    final children = _localFolder?.children ?? [];
    if (store.searchQuery.isEmpty) return children;

    final query = store.searchQuery.toLowerCase();
    return children
        .where((item) => item.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: CustomTopBar(
        title: widget.folderName ?? 'Pasta',
        showBackButton: true,
        onBackPressed: () {
          store.navigateBack();
          Navigator.of(context).pop();
        },
        authStore: _authStore,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final folder = _localFolder;

    if (folder == null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadFolder(forceRefresh: true),
      child: Observer(
        builder: (_) {
          // Observer necessário para reagir a mudanças no searchQuery
          final items = _filteredChildren;

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: [
              _buildBreadcrumb(folder),
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
            GestureDetector(
              onTap: () {
                store.navigateToStackIndex(-1);
                Modular.to.popUntil(ModalRoute.withName('/drive/'));
              },
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
                          onTap: isLast
                              ? null
                              : () {
                                  store.navigateToStackIndex(index);
                                  final pops =
                                      store.folderStack.length - 1 - index;
                                  for (var i = 0; i < pops; i++) {
                                    Navigator.of(context).pop();
                                  }
                                },
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
          if (_errorMessage != null && _errorMessage!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                _errorMessage!,
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

  void _handleItemTap(DriveItem item) {
    if (item.type == DriveItemType.folder) {
      store.navigateToFolder(item.id, item.name);

      Modular.to.pushNamed(
        './folder',
        arguments: {
          'folderId': item.id,
          'folderName': item.name,
        },
      );
    } else if (item.type == DriveItemType.video) {
      Modular.to.pushNamed(
        './video-player',
        arguments: item,
      );
    } else if (item.type == DriveItemType.image) {
      Modular.to.pushNamed(
        './image-viewer',
        arguments: item,
      );
    } else {
      FileDetailsModal.show(
        context: context,
        item: item,
        onOpen: () => fileOpenerStore.openFile(item),
        onDownload: () => _handleDownload(item),
      );
    }
  }

  Future<void> _handleDownload(DriveItem item) async {
    final savedPath = await fileOpenerStore.downloadFile(item);
    if (!mounted) return;

    if (savedPath != null) {
      final fileName = savedPath.split('/').last;
      final folderPath = savedPath.substring(0, savedPath.lastIndexOf('/'));
      final messageStr = Platform.isIOS
          ? 'O arquivo "$fileName" foi disponibilizado nos seus Arquivos'
          : 'O arquivo "$fileName" foi salvo em:\n$folderPath';
      CustomInfoDialog.show(
        context: context,
        type: DialogType.success,
        title: 'Download concluído',
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
}
