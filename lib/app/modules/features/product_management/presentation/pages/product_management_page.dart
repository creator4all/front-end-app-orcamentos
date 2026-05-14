import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/widgets/widgets.dart';

import '../../../../features/auth/presentation/stores/auth_store.dart';
import '../../domain/entities/product_config_entity.dart';
import '../stores/product_management_store.dart';
import '../widgets/category_card_widget.dart';
import '../widgets/product_config_card_widget.dart';
import '../widgets/product_edit_config_modal.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  late final ProductManagementStore _store;
  late final AuthStore _authStore;
  late final ScrollController _breadcrumbScrollController;

  @override
  void initState() {
    super.initState();
    _store = Modular.get<ProductManagementStore>();
    _authStore = Modular.get<AuthStore>();
    _breadcrumbScrollController = ScrollController();
    _store.loadCategories();
    _store.loadIndicators();
  }

  @override
  void dispose() {
    _breadcrumbScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomTopBar(
        title: 'Configurar Produtos',
        showBackButton: true,
        onBackPressed: _handleBack,
        authStore: _authStore,
      ),
      body: Observer(
        builder: (_) {
          if (_store.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_store.canGoBack) _buildBreadcrumb(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Text(
                  _store.pageTitle,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF484848),
                  ),
                ),
              ),
              Expanded(child: _buildContent()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBreadcrumb() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_breadcrumbScrollController.hasClients) {
        _breadcrumbScrollController.jumpTo(
          _breadcrumbScrollController.position.maxScrollExtent,
        );
      }
    });

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: SingleChildScrollView(
        controller: _breadcrumbScrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                _store.loadCategories();
              },
              child: Text(
                'Categorias',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF117BBD),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            if (_store.currentLevel == NavigationLevel.subcategories ||
                _store.currentLevel == NavigationLevel.products) ...[
              Icon(Icons.chevron_right, size: 16.sp, color: Colors.grey),
              GestureDetector(
                onTap: () {
                  if (_store.currentLevel == NavigationLevel.products) {
                    _store.goBack();
                  }
                },
                child: Text(
                  _store.selectedCategory?.nome ?? '',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _store.currentLevel == NavigationLevel.products
                        ? const Color(0xFF117BBD)
                        : const Color(0xFF484848),
                    decoration: _store.currentLevel == NavigationLevel.products
                        ? TextDecoration.underline
                        : null,
                  ),
                ),
              ),
            ],
            if (_store.currentLevel == NavigationLevel.products) ...[
              Icon(Icons.chevron_right, size: 16.sp, color: Colors.grey),
              Text(
                _store.selectedSubcategory?.nome ?? '',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF484848),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_store.currentLevel) {
      case NavigationLevel.categories:
        return _buildCategoriesList();
      case NavigationLevel.subcategories:
        return _buildSubcategoriesList();
      case NavigationLevel.products:
        return _buildProductsList();
    }
  }

  Widget _buildCategoriesList() {
    if (_store.categories.isEmpty) {
      return _buildEmptyState('Nenhuma categoria encontrada');
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: _store.categories.length,
      itemBuilder: (context, index) {
        final category = _store.categories[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: CategoryCardWidget(
            name: category.nome,
            subtitle: 'Subcategorias',
            onTap: () => _store.selectCategory(category),
          ),
        );
      },
    );
  }

  Widget _buildSubcategoriesList() {
    if (_store.subcategories.isEmpty) {
      return _buildEmptyState('Nenhuma subcategoria encontrada');
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: _store.subcategories.length,
      itemBuilder: (context, index) {
        final subcategory = _store.subcategories[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: CategoryCardWidget(
            name: subcategory.nome,
            subtitle: 'Produtos',
            onTap: () => _store.selectSubcategory(subcategory),
          ),
        );
      },
    );
  }

  Widget _buildProductsList() {
    if (_store.products.isEmpty) {
      return _buildEmptyState('Nenhum produto encontrado');
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: _store.products.length,
      itemBuilder: (context, index) {
        final product = _store.products[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: ProductConfigCardWidget(
            product: product,
            onInfoTap: () => _openEditModal(product.id),
            onStatusChanged: (value) => _toggleProductStatus(product, value),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _handleBack() {
    if (_store.canGoBack) {
      _store.goBack();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _openEditModal(int productId) async {
    await _store.loadProductDetails(productId);

    if (_store.selectedProduct != null && mounted) {
      await ProductEditConfigModal.show(
        context: context,
        product: _store.selectedProduct!,
        categoryName: _store.selectedCategory?.nome ?? '',
        subcategoryName: _store.selectedSubcategory?.nome ?? '',
        indicatorGroups: _store.indicatorGroups.toList(),
        onSave: (updatedProduct) => _store.updateProduct(updatedProduct),
      );

      _store.clearSelectedProduct();
    }
  }

  Future<void> _toggleProductStatus(
    ProductConfigEntity product,
    bool newStatus,
  ) async {
    final success = await _store.updateProductStatus(product.id, newStatus);
    if (!mounted) return;

    CustomInfoDialog.show(
      context: context,
      type: success ? DialogType.success : DialogType.error,
      title: success ? 'Sucesso' : 'Erro',
      message: success
          ? newStatus
              ? 'Produto reativado com sucesso.'
              : 'Produto desativado com sucesso.'
          : 'Erro ao desabilitar produto.',
      onButtonPressed: success
          ? null
          : () {
              if (_store.selectedSubcategory != null) {
                _store.selectSubcategory(_store.selectedSubcategory!);
              }
            },
    );
  }
}
