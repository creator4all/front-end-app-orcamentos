import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeleteAccountModal extends StatefulWidget {
  final String userName;
  final Future<void> Function() onConfirmDelete;
  final VoidCallback onCancel;

  const DeleteAccountModal({
    super.key,
    required this.userName,
    required this.onConfirmDelete,
    required this.onCancel,
  });

  @override
  State<DeleteAccountModal> createState() => _DeleteAccountModalState();
}

class _DeleteAccountModalState extends State<DeleteAccountModal> {
  final TextEditingController _confirmController = TextEditingController();
  bool _isDeleting = false;
  String? _errorMessage;

  static const String _confirmText = 'DELETAR';

  bool get _canDelete =>
      _confirmController.text.toUpperCase() == _confirmText && !_isDeleting;

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    if (!_canDelete) return;

    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });

    try {
      await widget.onConfirmDelete();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
          _errorMessage = 'Erro ao deletar conta: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE55353).withOpacity(0.1),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 40.sp,
                color: const Color(0xFFE55353),
              ),
            ),

            SizedBox(height: 16.h),

            Text(
              'Deletar Conta',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1C1B1F),
              ),
            ),

            SizedBox(height: 12.h),

            Text(
              'Esta ação é irreversível!',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE55353),
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8.h),

            Text(
              'Ao deletar sua conta, todos os seus dados serão permanentemente removidos e você será desconectado do aplicativo.',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 20.h),

            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF1C1B1F),
                ),
                children: const [
                  TextSpan(text: 'Digite '),
                  TextSpan(
                    text: _confirmText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE55353),
                    ),
                  ),
                  TextSpan(text: ' para confirmar:'),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            TextField(
              controller: _confirmController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Digite $_confirmText',
                hintStyle: TextStyle(
                  color: const Color(0xFF999999),
                  fontSize: 14.sp,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: Color(0xFFE55353)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),

            if (_errorMessage != null) ...[
              SizedBox(height: 12.h),
              Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFFE55353),
                ),
                textAlign: TextAlign.center,
              ),
            ],

            SizedBox(height: 24.h),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isDeleting ? null : widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF666666),
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: ElevatedButton(
                    onPressed: _canDelete ? _handleDelete : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE55353),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          const Color(0xFFE55353).withOpacity(0.5),
                      disabledForegroundColor: Colors.white70,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: _isDeleting
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Deletar',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}