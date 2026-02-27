import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../shared/utils/string_utils.dart';
import '../../domain/entities/product_entity.dart';

class ProductCheckbox extends StatelessWidget {
  final ProductEntity product;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTap;
  final bool showDetails;

  const ProductCheckbox({
    super.key,
    required this.product,
    required this.isSelected,
    required this.onChanged,
    required this.onTap,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? Colors.blue[300]! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: onChanged,
              activeColor: const Color(0xFF117BBD),
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.solucao,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  if (showDetails) ...[
                    Text(
                      product.indicacao,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          _getProductIcon(product.tipoProduto),
                          size: 12.sp,
                          color: const Color(0xFF117BBD),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          _getProductType(product.tipoProduto),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: const Color(0xFF117BBD),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        if (product.selecionado && product.quantidade > 0) ...[
                          Text(
                            'Qtd: ${product.quantidade}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'R\$ ${product.totalValue.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),

            if (showDetails)
              IconButton(
                onPressed: onTap,
                icon: Icon(
                  Icons.edit,
                  size: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  static const _productIcons = <String, IconData>{
    'livro': Icons.book,
    'tecnologia': Icons.computer,
    'serviço': Icons.miscellaneous_services,
  };

  IconData _getProductIcon(String tipoProduto) {
    return _productIcons[tipoProduto.toLowerCase()] ?? Icons.category;
  }

  String _getProductType(String tipoProduto) {
    return capitalizeFirstLetter(tipoProduto);
  }
}
