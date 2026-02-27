import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/entities/subcategory_entity.dart';

class ProductsModal extends StatefulWidget {
  final SubcategoryEntity subcategory;
  final Function(ProductEntity) onProductTap;
  final Function(int productId, bool selected) onProductToggle;
  final Function(int productId, int quantity) onQuantityChanged;

  const ProductsModal({
    super.key,
    required this.subcategory,
    required this.onProductTap,
    required this.onProductToggle,
    required this.onQuantityChanged,
  });

  @override
  State<ProductsModal> createState() => _ProductsModalState();
}

class _ProductsModalState extends State<ProductsModal> {
  final Map<int, bool> _localSelection = {};
  final Map<int, int> _localQuantities = {};

  @override
  void initState() {
    super.initState();
    for (var product in widget.subcategory.activeProdutos) {
      _localSelection[product.id] = product.selecionado;
      _localQuantities[product.id] = product.quantidade;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeProducts = widget.subcategory.activeProdutos;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),

          Divider(height: 1, color: Colors.grey[300]),

          Expanded(
            child: activeProducts.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: EdgeInsets.all(16.w),
                    itemCount: activeProducts.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final product = activeProducts[index];
                      return _ProductCard(
                        product: product,
                        isChecked: _localSelection[product.id] ?? false,
                        quantity: _localQuantities[product.id] ?? 1,
                        onChanged: (value) {
                          setState(() {
                            _localSelection[product.id] = value ?? false;
                          });
                        },
                        onQuantityChanged: (newQuantity) {
                          setState(() {
                            _localQuantities[product.id] = newQuantity;
                          });
                        },
                        onTap: () {
                          widget.onProductTap(product);
                        },
                      );
                    },
                  ),
          ),

          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Icon(
            Icons.folder,
            color: const Color(0xFF117BBD),
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.subcategory.nome,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF117BBD),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${widget.subcategory.activeProductsCount} produtos disponíveis',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'Nenhum produto disponível',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: ElevatedButton(
          onPressed: () {
            _localSelection.forEach((productId, selected) {
              widget.onProductToggle(productId, selected);
            });
            _localQuantities.forEach((productId, quantity) {
              widget.onQuantityChanged(productId, quantity);
            });
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF117BBD),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text(
            'Aplicar',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Card de produto
class _ProductCard extends StatelessWidget {
  final ProductEntity product;
  final bool isChecked;
  final int quantity;
  final ValueChanged<bool?> onChanged;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.isChecked,
    required this.quantity,
    required this.onChanged,
    required this.onQuantityChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isChecked ? const Color(0xFF117BBD) : Colors.grey[300]!,
          width: isChecked ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24.w,
                height: 24.h,
                child: Checkbox(
                  value: isChecked,
                  onChanged: onChanged,
                  activeColor: const Color(0xFF117BBD),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.solucao,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Código: ${product.codigo}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.info_outline,
                  size: 20.sp,
                  color: const Color(0xFF117BBD),
                ),
                onPressed: onTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          Row(
            children: [
              Expanded(
                child: Text(
                  product.indicacao,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                product.formattedValue,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF117BBD),
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quantidade:',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[700],
                ),
              ),
              _QuantitySelector(
                quantity: quantity,
                onChanged: onQuantityChanged,
                enabled: isChecked,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Seletor de quantidade
class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final bool enabled;

  const _QuantitySelector({
    required this.quantity,
    required this.onChanged,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.remove_circle_outline, size: 20.sp),
          onPressed:
              enabled && quantity > 1 ? () => onChanged(quantity - 1) : null,
          color: const Color(0xFF117BBD),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        SizedBox(width: 8.w),
        Container(
          width: 40.w,
          height: 32.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey[100],
            border: Border.all(
              color: enabled ? const Color(0xFF117BBD) : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            '$quantity',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: enabled ? Colors.black87 : Colors.grey[400],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        IconButton(
          icon: Icon(Icons.add_circle_outline, size: 20.sp),
          onPressed: enabled ? () => onChanged(quantity + 1) : null,
          color: const Color(0xFF117BBD),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
