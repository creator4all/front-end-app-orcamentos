import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobx/mobx.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_info_dialog.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_top_bar.dart';

import '../../../auth/presentation/stores/auth_store.dart';
import '../../domain/entities/drive_item.dart';
import '../stores/file_opener_store.dart';
import '../stores/new_drive_store.dart';
import '../widgets/category_card.dart';
import '../widgets/file_details_modal.dart';
import '../widgets/item_card_doc.dart';

class NewDrivePage extends StatefulWidget {
  const NewDrivePage({super.key});

  @override
  State<NewDrivePage> createState() => _NewDrivePageState();
}

class _NewDrivePageState extends State<NewDrivePage> {
  final NewDriveStore store = Modular.get<NewDriveStore>();
  final FileOpenerStore fileOpenerStore = Modular.get<FileOpenerStore>();
  final AuthStore authStore = Modular.get<AuthStore>();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    store.folderStack.clear();
    store.currentFolder = null;

    store.initialize();
    reaction(
      (_) => fileOpenerStore.errorMessage,
      (String? errorMessage) {
        if (errorMessage != null && errorMessage.isNotEmpty) {
          CustomInfoDialog.show(
            context: context,
            type: DialogType.error,
            title: 'Erro',
            message: errorMessage,
          );
          fileOpenerStore.clearError();
        }
      },
    );
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
        title: 'Multi Drive',
        showBackButton: true,
        authStore: authStore,
      ),
      body: Observer(
        builder: (_) {
          if (store.isLoading && store.recentItems.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Column(
                              children: [
                                SizedBox(height: 16.h),
                                _buildSearchField(),
                              ],
                            ),
                          ),

                          Observer(
                            builder: (_) {
                              if (store.recentItems.isNotEmpty) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 24.h),
                                  child: _buildRecentSection(),
                                );
                              }
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 48.h),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.folder_open_outlined,
                                        size: 48.sp,
                                        color: const Color(0xFF9095A0),
                                      ),
                                      SizedBox(height: 12.h),
                                      Text(
                                        authStore.isAdmin
                                            ? 'Nenhum item compartilhado com você\nou enviado por você'
                                            : 'Nenhum item compartilhado com você ainda',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: const Color(0xFF565E6C),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Column(
                              children: [
                                if (authStore.isAdmin) ...[
                                  _buildMyFilesButton(),
                                  SizedBox(height: 12.h),
                                ],

                                _buildSharedFilesButton(),

                                SizedBox(height: 16.h),
                              ],
                            ),
                          ),

                          _buildCategoriesSection(),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
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

  Widget _buildRecentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Compartilhados recentemente',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF171A1F),
          ),
        ),
        SizedBox(height: 12.h),

        Observer(
          builder: (_) {
            final items = store.recentItems.take(4).toList();

            if (items.isEmpty) {
              return _buildEmptyState('Nenhum arquivo recente');
            }

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildRecentItemCard(items.elementAtOrNull(0)),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildRecentItemCard(items.elementAtOrNull(1)),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildRecentItemCard(items.elementAtOrNull(2)),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildRecentItemCard(items.elementAtOrNull(3)),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentItemCard(DriveItem? item) {
    if (item == null) {
      return const SizedBox.shrink();
    }

    return ItemCardDoc(
      item: item,
      maxNameLines: 2,
      showMenu: false,
      onTap: item.type == DriveItemType.folder
          ? () => _handleFileOpen(item)
          : () => _showFileDetails(item),
    );
  }

  void _showFileDetails(DriveItem item) {
    FileDetailsModal.show(
      context: context,
      item: item,
      onOpen: () => _handleFileOpenAsync(item),
      onDownload: () => _handleDownloadAsync(item),
    );
  }

  Future<void> _handleFileOpenAsync(DriveItem item) async {
    await _handleFileOpen(item);
  }
  Future<void> _handleDownloadAsync(DriveItem item) async {
    await fileOpenerStore.openFile(item);
  }

  Widget _buildMyFilesButton() {
    return InkWell(
      onTap: () {
        Modular.to.pushNamed('./my-files');
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFBCC1CA),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Meus arquivos',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF171A1F),
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: const Color(0xFF2830F2),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSharedFilesButton() {
    return InkWell(
      onTap: () {
        Modular.to.pushNamed('./shared-files');
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFBCC1CA),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Todos os arquivos compartilhados',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF171A1F),
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: const Color(0xFF2830F2),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(6),
        ),
      ),
      padding: EdgeInsets.all(10.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categorias',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF171A1F),
                ),
              ),
              Icon(
                Icons.grid_view,
                color: const Color(0xFF565E6C),
                size: 20.sp,
              ),
            ],
          ),
          SizedBox(height: 16.h),

          Observer(
            builder: (_) {
              final categories = store.categories;

              if (categories.isEmpty) {
                return _buildEmptyState('Nenhuma categoria disponível');
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 2.5,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return CategoryCard(
                    categoryName: category.name,
                    categoryType: category.type,
                    itemCount: category.itemCount,
                    totalSize: category.totalSize,
                    onTap: () {
                      Modular.to.pushNamed(
                        './category',
                        arguments: category.type,
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF565E6C),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> _handleFileOpen(DriveItem item) async {
    if (item.type == DriveItemType.folder) {
      store.navigateToFolder(item.id, item.name);
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
      Modular.to.pushNamed('./video-player', arguments: item);
      return;
    }
    if (item.type == DriveItemType.image) {
      Modular.to.pushNamed('./image-viewer', arguments: item);
      return;
    }

    _showLoadingDialog();
    await fileOpenerStore.openFile(item);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Observer(
        builder: (_) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 16.h),
              Text(
                'Baixando arquivo...',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF171A1F),
                ),
              ),
              if (fileOpenerStore.downloadProgress > 0) ...[
                SizedBox(height: 8.h),
                Text(
                  '${fileOpenerStore.progressPercentage}%',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF565E6C),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
