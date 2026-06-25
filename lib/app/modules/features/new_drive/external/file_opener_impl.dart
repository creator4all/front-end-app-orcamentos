import 'package:open_filex/open_filex.dart';

import '../domain/repositories/file_opener.dart';

class FileOpenerImpl implements FileOpener {
  @override
  Future<FileOpenResult> open(String path) async {
    final result = await OpenFilex.open(path);

    final type = switch (result.type) {
      ResultType.done => FileOpenResultType.done,
      ResultType.noAppToOpen => FileOpenResultType.noAppToOpen,
      ResultType.permissionDenied => FileOpenResultType.permissionDenied,
      ResultType.fileNotFound => FileOpenResultType.fileNotFound,
      _ => FileOpenResultType.error,
    };

    return FileOpenResult(type: type, message: result.message);
  }
}
