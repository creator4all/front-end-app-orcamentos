class DownloadCancelToken {
  void Function()? _onCancel;
  bool _isCanceled = false;

  bool get isCanceled => _isCanceled;

  void onCancel(void Function() callback) {
    _onCancel = callback;
  }

  void cancel() {
    if (_isCanceled) return;
    _isCanceled = true;
    _onCancel?.call();
  }
}
