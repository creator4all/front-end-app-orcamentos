import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/presentation/widgets/drive_item_list_view.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_top_bar.dart';

import '../../../auth/presentation/stores/auth_store.dart';
import '../../domain/entities/drive_item.dart';
import '../stores/file_opener_store.dart';
import '../stores/new_drive_store.dart';

class CategoryDetailsPage extends StatefulWidget {
  final DriveItemType categoryType;

  const CategoryDetailsPage({
    super.key,
    required this.categoryType,
  });

  @override
  State<CategoryDetailsPage> createState() => _CategoryDetailsPageState();
}

class _CategoryDetailsPageState extends State<CategoryDetailsPage> {
  final NewDriveStore store = Modular.get<NewDriveStore>();
  final FileOpenerStore fileOpenerStore = Modular.get<FileOpenerStore>();
  final AuthStore _authStore = Modular.get<AuthStore>();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    store.selectCategory(widget.categoryType);
  }

  @override
  void dispose() {
    store.clearSelectedCategory();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: CustomTopBar(
        title: _getCategoryTitle(widget.categoryType),
        showBackButton: true,
        authStore: _authStore,
      ),
      body: Column(
        children: [
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
                'Arquivos compartilhados com você',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF565E6C),
                ),
              ),
            ),
          ),
          Expanded(
            child: Observer(
              builder: (_) {
                final items = store.filteredCategoryItems;
                if (items.isEmpty) {
                  return _buildEmptyState();
                }
                return DriveItemListView(
                  items: items,
                  onItemTap: _handleFileOpen,
                  onMenuTap: (item) {},
                );
              },
            ),
          ),
        ],
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

  void _handleFileOpen(DriveItem item) {
    if (item.type == DriveItemType.folder) {
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
      fileOpenerStore.openFile(item);
    }
  }

  Widget _buildEmptyState() {
    final categoryName = _getCategoryTitle(widget.categoryType).toLowerCase();
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
            'Nenhum $categoryName encontrado',
            style: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFF565E6C),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryTitle(DriveItemType type) {
    switch (type) {
      case DriveItemType.document:
        return 'Documentos';
      case DriveItemType.image:
        return 'Imagens';
      case DriveItemType.video:
        return 'Vídeos';
      case DriveItemType.folder:
        return 'Pastas';
    }
  }
}
