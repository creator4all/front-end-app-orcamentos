import 'package:equatable/equatable.dart';

abstract class NewDriveFailure extends Equatable {
  final String message;

  const NewDriveFailure(this.message);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [message];
}

class LoadRecentItemsFailure extends NewDriveFailure {
  const LoadRecentItemsFailure(super.message);
}

class ConnectionFailure extends NewDriveFailure {
  const ConnectionFailure(super.message);
}

class DownloadFileFailure extends NewDriveFailure {
  const DownloadFileFailure(super.message);
}

class DownloadCancelledFailure extends NewDriveFailure {
  const DownloadCancelledFailure(super.message);
}

class NoAppToOpenFailure extends NewDriveFailure {
  const NoAppToOpenFailure(super.message);
}

class PermissionDeniedFailure extends NewDriveFailure {
  const PermissionDeniedFailure(super.message);
}

class FileNotFoundFailure extends NewDriveFailure {
  const FileNotFoundFailure(super.message);
}
