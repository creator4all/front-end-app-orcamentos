import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_top_bar.dart';

import '../../../../features/auth/presentation/stores/auth_store.dart';
import '../../domain/entities/drive_item.dart';
import '../stores/file_opener_store.dart';
import '../stores/new_drive_store.dart';
import '../widgets/item_card_doc.dart';
import '../widgets/drive_item_details.dart';

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

    if (!authStore.isAdmin) {
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

    store.setViewMode('my-files');
  }

  @override
  void dispose() {
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
      body: RefreshIndicator(
        onRefresh: () => store.loadOwnFiles(),
        child: Observer(
          builder: (_) {
            final items = store.filteredViewItems;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
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
                      'Arquivos que você enviou',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF565E6C),
                      ),
                    ),
                  ),
                ),
                if (items.isEmpty)
                  _buildEmptyState()
                else
                  ...items.map((item) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Column(
                      children: [
                        ItemCardDoc(
                          item: item,
                          showMenu: false,
                          onTap: () => _showFileDetails(item),
                        ),
                        SizedBox(height: 12.h),
                      ],
                    ),
                  )),
              ],
            );
          },
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

  void _showFileDetails(DriveItem item) {
    DriveItemDetails.show(
      context: context,
      item: item,
      fileOpenerStore: fileOpenerStore,
      onOpen: _handleFileOpen,
    );
  }

  void _handleFileOpen(DriveItem item) {
    if (item.type == DriveItemType.folder) {
      Modular.to.pushNamed(
        '/drive/folder',
        arguments: {
          'folderId': item.id,
          'folderName': item.name,
        },
      );
    } else if (item.type == DriveItemType.video) {
      Modular.to.pushNamed(
        '/drive/video-player',
        arguments: item,
      );
    } else if (item.type == DriveItemType.image) {
      Modular.to.pushNamed(
        '/drive/image-viewer',
        arguments: item,
      );
    } else {
      fileOpenerStore.openFile(item);
    }
  }
}
