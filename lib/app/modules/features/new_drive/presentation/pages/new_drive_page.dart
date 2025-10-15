import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobx/mobx.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_top_bar.dart';

import '../../domain/entities/drive_item.dart';
import '../stores/file_opener_store.dart';
import '../stores/new_drive_store.dart';
import '../widgets/category_card.dart';
import '../widgets/item_card_doc.dart';

/// Tela principal do módulo Multi Drive
///
/// Exibe:
/// - Campo de busca
/// - Seção de arquivos compartilhados recentemente (limitado a 4)
/// - Botão para meus arquivos (apenas administradores)
/// - Botão para todos os arquivos compartilhados
/// - Seção de categorias (Documentos, Imagens, Vídeos, Pastas)
class NewDrivePage extends StatefulWidget {
  const NewDrivePage({super.key});

  @override
  State<NewDrivePage> createState() => _NewDrivePageState();
}

class _NewDrivePageState extends State<NewDrivePage> {
  final NewDriveStore store = Modular.get<NewDriveStore>();
  final FileOpenerStore fileOpenerStore = Modular.get<FileOpenerStore>();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Carregar dados iniciais
    store.initialize();

    // Observar erros da FileOpenerStore e mostrar SnackBar
    reaction(
      (_) => fileOpenerStore.errorMessage,
      (String? errorMessage) {
        if (errorMessage != null && errorMessage.isNotEmpty) {
          _showErrorSnackBar(errorMessage);
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
    // TODO: Verificar se usuário é administrador (integrar com AuthStore)
    const bool isAdmin = true; // Placeholder - substituir por verificação real

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: const CustomTopBar(
        title: 'Multi Drive',
        showBackButton: true,
      ),
      body: Observer(
        builder: (_) {
          if (store.isLoading && store.recentItems.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Conteúdo com padding lateral
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),

                      // Campo de busca
                      _buildSearchField(),

                      SizedBox(height: 24.h),

                      // Seção de vistos recentemente (apenas se houver itens)
                      Observer(
                        builder: (_) {
                          if (store.recentItems.isNotEmpty) {
                            return Column(
                              children: [
                                _buildRecentSection(),
                                SizedBox(height: 24.h),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // Botão "Meus arquivos" (apenas para admin)
                      if (isAdmin) ...[
                        _buildMyFilesButton(),
                        SizedBox(height: 12.h),
                      ],

                      // Botão de todos os arquivos compartilhados
                      _buildSharedFilesButton(),

                      SizedBox(height: 24.h),
                    ],
                  ),
                ),

                // Seção de categorias (largura total, dentro do scroll)
                _buildCategoriesSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Campo de busca de arquivos
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

  /// Seção de arquivos compartilhados recentemente
  Widget _buildRecentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        Text(
          'Compartilhados recentemente',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF171A1F),
          ),
        ),
        SizedBox(height: 12.h),

        // Grid de 2x2 com arquivos recentes
        Observer(
          builder: (_) {
            final items = store.recentItems.take(4).toList();

            if (items.isEmpty) {
              return _buildEmptyState('Nenhum arquivo recente');
            }

            return Column(
              children: [
                // Primeira linha (2 cards)
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
                // Segunda linha (2 cards)
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

  /// Constrói um card de item recente
  Widget _buildRecentItemCard(DriveItem? item) {
    if (item == null) {
      return const SizedBox.shrink();
    }

    return ItemCardDoc(
      itemName: item.name,
      itemSize: item.size,
      itemDate: item.getFormattedDate(),
      itemType: item.type,
      thumbnailUrl: item.thumbnailUrl,
      onTap: () => _handleFileOpen(item),
      onMenuTap: () {
        // TODO: Implementar menu de opções
        debugPrint('Menu tap on item: ${item.name}');
      },
    );
  }

  /// Botão para meus arquivos (apenas administrador)
  Widget _buildMyFilesButton() {
    return InkWell(
      onTap: () {
        // TODO: Implementar navegação para meus arquivos
        debugPrint('Navigate to my files');
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

  /// Botão para todos os arquivos compartilhados
  Widget _buildSharedFilesButton() {
    return InkWell(
      onTap: () {
        // TODO: Implementar navegação para todos os arquivos
        debugPrint('Navigate to all shared files');
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

  /// Seção de categorias de arquivos
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
        children: [
          // Header da seção
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

          // Grid de categorias
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
                  childAspectRatio: 1.3,
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
                      // TODO: Implementar navegação para categoria
                      debugPrint('Navigate to category: ${category.name}');
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

  /// Estado vazio genérico
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

  /// Manipula a abertura de um arquivo
  Future<void> _handleFileOpen(DriveItem item) async {
    // Detectar tipo de arquivo e rotear apropriadamente
    final fileName = item.name.toLowerCase();

    // 1. Vídeos -> Streaming player
    if (_isVideo(fileName)) {
      Modular.to.pushNamed('/drive/video-player', arguments: item);
      return;
    }

    // 2. Imagens -> Viewer com zoom
    if (_isImage(fileName)) {
      Modular.to.pushNamed('/drive/image-viewer', arguments: item);
      return;
    }

    // 3. Documentos/PDFs/outros -> Download + App nativo (comportamento atual)
    _showLoadingDialog();
    await fileOpenerStore.openFile(item);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Verifica se é um vídeo
  bool _isVideo(String fileName) {
    final extension = fileName.split('.').last;
    return ['mp4', 'avi', 'mov', 'mkv', 'webm', '3gp', 'flv', 'wmv']
        .contains(extension);
  }

  /// Verifica se é uma imagem
  bool _isImage(String fileName) {
    final extension = fileName.split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  /// Exibe modal de loading durante download
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

  /// Exibe SnackBar com mensagem de erro
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
