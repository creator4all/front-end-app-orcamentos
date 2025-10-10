import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/widgets/custom_top_bar.dart';
import '../../../../shared/widgets/file_item_widget.dart';
import '../stores/drive_store.dart';

class DrivePage extends StatefulWidget {
  const DrivePage({super.key});

  @override
  State<DrivePage> createState() => _DrivePageState();
}

class _DrivePageState extends State<DrivePage> {
  late final DriveStore _store;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = Modular.get<DriveStore>();
    _store.loadFiles();
  }

  void _handleFileTap(file) {
    if (file.canOpen) {
      _store.openFile(file);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Abrindo ${file.name}...'),
          backgroundColor: const Color(0xFF1C94DF),
        ),
      );
    }
  }

  void _handleDownload(file) {
    _store.downloadFile(file);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Baixando ${file.name}...'),
        backgroundColor: const Color(0xFF0E3562),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopBar(
        title: 'Drive',
        showBackButton: true,
        userName: 'Pedro Penha',
        userEmail: 'pedro.penha.martins@gmail.com',
        userDocument: '03.848.869/0001-89',
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Arquivos Compartilhados',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: const Color(0xFF484848),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _store.loadFiles(),
                    icon: Icon(
                      Icons.refresh,
                      color: const Color(0xFF1C94DF),
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ),

            // Lista de arquivos
            Expanded(
              child: Observer(
                builder: (_) {
                  if (_store.isLoading && _store.files.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (_store.error != null && _store.files.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Erro: ${_store.error}'),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () => _store.loadFiles(),
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (_store.files.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () => _store.loadFiles(),
                      child: ListView(
                        children: [
                          SizedBox(height: 200.h),
                          const Center(
                            child: Text('Nenhum arquivo encontrado'),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => _store.loadFiles(),
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      itemCount: _store.files.length,
                      itemBuilder: (context, index) {
                        final file = _store.files[index];
                        return FileItemWidget(
                          file: file,
                          onTap: () => _handleFileTap(file),
                          onDownload: () => _handleDownload(file),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
