import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/wiki_content.dart';
import '../stores/wiki_store.dart';

/// Widget de tile expansível para itens da Wiki
class WikiExpansionTile extends StatelessWidget {
  final WikiItem item;
  final WikiStore store;

  const WikiExpansionTile({
    super.key,
    required this.item,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final isExpanded = store.isExpanded(item.id);

        return ExpansionTile(
          key: PageStorageKey(item.id),
          title: Text(
            item.title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Colors.grey,
          ),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) => store.toggleItem(item.id),
          tilePadding: EdgeInsets.symmetric(vertical: 8.h),
          childrenPadding: EdgeInsets.only(bottom: 16.h),
          children: _buildContent(),
        );
      },
    );
  }

  List<Widget> _buildContent() {
    final widgets = <Widget>[];

    // Conteúdo direto do item
    if (item.content != null) {
      widgets.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            item.content!,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),
      );
    }

    // Subitens aninhados (ex: "Página inicial" > "Vendedor")
    if (item.subItems != null) {
      for (final subItem in item.subItems!) {
        widgets.add(
          Observer(
            builder: (_) {
              final isSubExpanded = store.isExpanded(subItem.id);

              return ExpansionTile(
                key: PageStorageKey(subItem.id),
                title: Text(
                  subItem.title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                trailing: Icon(
                  isSubExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
                initiallyExpanded: isSubExpanded,
                onExpansionChanged: (expanded) => store.toggleItem(subItem.id),
                tilePadding: EdgeInsets.symmetric(horizontal: 16.w),
                childrenPadding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  bottom: 16.h,
                ),
                children: [
                  Text(
                    subItem.content,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }
    }

    return widgets;
  }
}
