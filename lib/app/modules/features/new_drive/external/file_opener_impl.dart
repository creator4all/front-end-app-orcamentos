import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';

import '../domain/repositories/file_opener.dart';

typedef OpenFile = Future<OpenResult> Function(
  String path, {
  String? type,
  String? uti,
});

class FileOpenerImpl implements FileOpener {
  final OpenFile _openFile;

  FileOpenerImpl({OpenFile? openFile}) : _openFile = openFile ?? OpenFilex.open;

  @override
  Future<FileOpenResult> open(
    String path, {
    String? mimeType,
    String? uti,
  }) async {
    try {
      final result = await _openFile(
        path,
        type: mimeType,
        uti: uti,
      );

      final type = switch (result.type) {
        ResultType.done => FileOpenResultType.done,
        ResultType.noAppToOpen => FileOpenResultType.noAppToOpen,
        ResultType.permissionDenied => FileOpenResultType.permissionDenied,
        ResultType.fileNotFound => FileOpenResultType.fileNotFound,
        _ => FileOpenResultType.error,
      };

      return FileOpenResult(type: type, message: result.message);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[FILE OPEN] Failed with ${error.runtimeType}');
      }
      return FileOpenResult(
        type: FileOpenResultType.error,
        message: error.runtimeType.toString(),
      );
    }
  }
}
