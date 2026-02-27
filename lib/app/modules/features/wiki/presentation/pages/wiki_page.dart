import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../shared/widgets/custom_top_bar.dart';
import '../../data/wiki_content.dart';
import '../stores/wiki_store.dart';
import '../widgets/wiki_expansion_tile.dart';

/// Página principal da Wiki com lista de itens colapsáveis
class WikiPage extends StatefulWidget {
  const WikiPage({super.key});

  @override
  State<WikiPage> createState() => _WikiPageState();
}

class _WikiPageState extends State<WikiPage> {
  final store = Modular.get<WikiStore>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(
        title: 'Wiki',
        showBackButton: true,
        onBackPressed: () => Modular.to.pop(),
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: WikiContent.items.length,
        separatorBuilder: (_, __) => Divider(height: 1.h),
        itemBuilder: (context, index) {
          final item = WikiContent.items[index];
          return WikiExpansionTile(
            item: item,
            store: store,
          );
        },
      ),
    );
  }
}
