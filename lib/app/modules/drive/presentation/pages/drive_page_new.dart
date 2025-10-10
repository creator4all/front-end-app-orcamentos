import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/widgets/custom_top_bar.dart';
import '../../domain/models/file_item.dart';
import '../stores/drive_store.dart';
import '../stores/my_files_store.dart';
import '../stores/shared_files_store.dart';
import '../widgets/file_action_dialog.dart';
import '../widgets/file_card_widget.dart';

class DrivePageNew extends StatefulWidget {
  const DrivePageNew({super.key});

  @override
  State<DrivePageNew> createState() => _DrivePageNewState();
}

class _DrivePageNewState extends State<DrivePageNew>
    with SingleTickerProviderStateMixin {
  late final DriveStore _driveStore;
  late final SharedFilesStore _sharedFilesStore;
  late final MyFilesStore _myFilesStore;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _driveStore = Modular.get<DriveStore>();
    _sharedFilesStore = Modular.get<SharedFilesStore>();
    _myFilesStore = Modular.get<MyFilesStore>();

    // Initialize tab controller based on admin status
    _tabController = TabController(
      length: _driveStore.isAdmin ? 2 : 1,
      vsync: this,
    );

    // Load initial files
    _loadFiles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    await _sharedFilesStore.loadSharedFiles();
    if (_driveStore.isAdmin) {
      await _myFilesStore.loadMyFiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Scaffold(
        backgroundColor: Colors.white,
        appBar: _driveStore.isAdmin
            ? _buildAppBarWithTabs()
            : const CustomTopBar(
                title: 'Drive',
                showBackButton: true,
              ),
        body: _driveStore.isAdmin
            ? _buildTabView()
            : _buildFilesList(_sharedFilesStore),
      ),
    );
  }

  PreferredSizeWidget _buildAppBarWithTabs() {
    return PreferredSize(
      preferredSize: Size.fromHeight(120.h),
      child: Column(
        children: [
          const CustomTopBar(
            title: 'Drive',
            showBackButton: true,
          ),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF2830F2),
              indicatorWeight: 3.h,
              labelColor: const Color(0xFF484848),
              unselectedLabelColor: const Color(0xFF828282),
              labelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              tabs: const [
                Tab(text: 'Compartilhados'),
                Tab(text: 'Meus Arquivos'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildFilesList(_sharedFilesStore),
        _buildFilesList(_myFilesStore),
      ],
    );
  }

  Widget _buildFilesList(dynamic store) {
    return Observer(
      builder: (_) {
        if (store.isLoading && store.files.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2830F2),
            ),
          );
        }

        if (store.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.sp,
                  color: const Color(0xFF828282),
                ),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Text(
                    store.error!,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xFF484848),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () async {
                    if (store is SharedFilesStore) {
                      await store.loadSharedFiles();
                    } else if (store is MyFilesStore) {
                      await store.loadMyFiles();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2830F2),
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 12.h,
                    ),
                  ),
                  child: Text(
                    'Tentar novamente',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (store.files.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 64.sp,
                  color: const Color(0xFF828282),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Nenhum arquivo encontrado',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF484848),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (store is SharedFilesStore) {
              await store.loadSharedFiles();
            } else if (store is MyFilesStore) {
              await store.loadMyFiles();
            }
          },
          color: const Color(0xFF2830F2),
          child: Column(
            children: [
              // Breadcrumb navigation
              if (store.breadcrumb.isNotEmpty) _buildBreadcrumb(store),

              // Files grid
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: store.files.length,
                    itemBuilder: (context, index) {
                      final file = store.files[index];
                      final isDownloaded =
                          store.downloadedFiles.contains(file.id);

                      return FileCardWidget(
                        file: file,
                        isDownloaded: isDownloaded,
                        onTap: () => _handleFileTap(file, store),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreadcrumb(dynamic store) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE0E0E0),
            width: 1.w,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Home icon
            GestureDetector(
              onTap: () => store.navigateToRoot(),
              child: Icon(
                Icons.home,
                size: 20.sp,
                color: const Color(0xFF484848),
              ),
            ),

            // Breadcrumb items
            ...store.breadcrumb.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == store.breadcrumb.length - 1;

              return Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Icon(
                      Icons.chevron_right,
                      size: 16.sp,
                      color: const Color(0xFF828282),
                    ),
                  ),
                  GestureDetector(
                    onTap:
                        isLast ? null : () => store.navigateToBreadcrumb(index),
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isLast
                            ? const Color(0xFF2830F2)
                            : const Color(0xFF484848),
                        fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void _handleFileTap(FileItem file, dynamic store) {
    if (file.isFolder) {
      store.navigateToFolder(file);
    } else {
      // Mostrar dialog com opções
      _showFileActionDialog(file, store);
    }
  }

  void _showFileActionDialog(FileItem file, dynamic store) {
    final isDownloaded = store.downloadedFiles.contains(file.id);

    showDialog(
      context: context,
      builder: (context) => FileActionDialog(
        file: file,
        sharedByName: file.uploaderName,
        isDownloaded: isDownloaded,
        onOpen: () => _handleOpen(file, store),
        onDownload: () => _handleDownload(file, store),
      ),
    );
  }

  Future<void> _handleOpen(FileItem file, dynamic store) async {
    try {
      await store.openFileWithNativeApp(file);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao abrir arquivo: $e',
            style: TextStyle(fontSize: 14.sp),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleDownload(FileItem file, dynamic store) async {
    try {
      await store.downloadFile(file);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Download de ${file.name} concluído',
            style: TextStyle(fontSize: 14.sp),
          ),
          backgroundColor: const Color(0xFF66BB6A),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao baixar arquivo: $e',
            style: TextStyle(fontSize: 14.sp),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
